#
# Cookbook Name:: dynatrace
# Libraries:: helpers
#
# Copyright 2015, Dynatrace
#

require 'fileutils'
require 'net/http'
require 'open-uri'
require 'socket'
require 'timeout'
require 'tmpdir'

module Dynatrace
  # Misc. helper methods used by throughout this cookbook
  module Helpers
    # Customized Timeout error
    class DynatraceTimeout < Timeout::Error; end

    # Exception used to inform that a connection endpoint (listening port, REST WS) is still not available
    class DynatraceNotReady < StandardError
      def initialize(endpoint, timeout)
        super <<-EOH
The Dynatrace Server at `#{endpoint}' did not become ready within #{timeout} seconds.
Possibly, Dynatrace has failed to start. Please check your Dynatrace Server log files.
EOH
      end
    end

    def self.read_file2out(description, file)
      puts description.to_s
      File.readlines(file.to_s).each do |line|
        puts line
      end
    end

    def self.file_append_or_replace_line(path, regex, line)
      FileUtils.touch(path) unless ::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      unless file.insert_line_if_no_match(/#{regex}/, line)
        file.search_file_replace_line(/#{regex}/, line)
      end
      file.write_file
    end

    # NOTE: this method loads whole content of a file into memory
    # before doing the pattern substitution
    def self.file_replace(path, regex, subst)
      data = File.read(path, :mode => 'r+')
      data.gsub!(/#{regex}/, subst)
      File.open(path, 'w') do |f|
        f.write(data)
      end
    end

    def self.find_line_in_file(path, regex)
      File.open(path) do |file|
        file.find_all do |line|
          puts line if line =~ /#{regex}/
        end
      end
    end

    def self.file_replace_line(path, regex, replace)
      FileUtils.touch(path) unless ::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      file.search_file_replace_line(/#{regex}/, replace)
      file.write_file
    end

    def self.get_install_dir_from_installer_tar(installer_path)
      # extract the dynatrace.x.y.z directory name from the contained installer shell script
      install_dir = nil
      Dir.mktmpdir do |tmpdir|
        install_dir = Mixlib::ShellOut.new("tar -xf #{installer_path} -C #{tmpdir} && cd #{tmpdir} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2", :cwd => File.dirname(installer_path)).run_command.stdout.strip
        if install_dir.empty?
          Dir.chdir
          dynatrace_dirs = Dir["#{tmpdir}/dynatrace*"]
          dynatrace_dirs.each do |elem|
            if File.directory?(elem)
              install_dir = File.basename elem
              break
            end
          end
        end
      end
      install_dir
    end

    def self.get_install_dir_from_installer_jar(installer_path)
      # extract the Manifest file
      cwd = File.dirname(installer_path)
      Mixlib::ShellOut.new("jar -xf #{installer_path} META-INF/MANIFEST.MF", :cwd => cwd).run_command

      prefix, ver_rev, ver_maj, ver_min = get_version_from_manifest "#{cwd}/META-INF/MANIFEST.MF"
      # Use a default prefix if prefix attribute not present in the Manifest file
      # The logic below is taken from the AbstractInstaller class in the Dynatrace jars
      install_dir = prefix ? prefix : "dynatrace-#{ver_maj}.#{ver_min}#{ver_rev}"

      # remove temporary directories
      Mixlib::ShellOut.new('rm -rf META-INF', :cwd => File.dirname(installer_path)).run_command

      install_dir
    end

    # private_class_method
    def self.get_version_from_manifest(file_path)
      prefix = nil
      ver_rev = '' # optional
      ver_maj = nil
      ver_min = nil
      File.open(file_path).each do |line|
        prefix = Regexp.last_match(1) if /prefix:\s*(\S+)/ =~ line
        break if prefix
        ver_maj = Regexp.last_match(1) if /version-major:\s*(\S+)/ =~ line
        ver_min = Regexp.last_match(1) if /version-minor:\s*(\S+)/ =~ line
        ver_rev = ".#{Regexp.last_match(1)}" if /version-revision:\s*(\S+)/ =~ line
      end
      [prefix, ver_rev, ver_maj, ver_min]
    end

    def self.get_install_dir_from_installer(installer_path, type = :jar)
      if type == :jar
        install_dir = get_install_dir_from_installer_jar(installer_path)
      end

      if type == :tar
        install_dir = get_install_dir_from_installer_tar(installer_path)
      end

      install_dir
    end

    def self.get_last_install_path(installer_prefix_dir)
      cmd = "find . -maxdepth 1 -name dynatrace-\\* -type d -printf \'%T@ %p\' | sort -k 1nr | cut -d\' \' -f2 | head -1 | xargs basename | xargs echo -n"
      shell = Mixlib::ShellOut.new(cmd, :cwd => installer_prefix_dir)
      shell.run_command

      "#{installer_prefix_dir}/#{shell.stdout}"
    end

    # private_class_method
    def self.port_is_open?(ip, port)
      s = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      sa = Socket.sockaddr_in(port, ip)

      begin
        s.connect_nonblock(sa)
        return true
      rescue IO::WaitWritable
        if IO.select(nil, [s], nil, 1)
          begin
            s.connect_nonblock(sa)
            return true
          rescue Errno::EISCONN
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          ensure
            s.close unless s.closed?
          end
        end
      end

      s.close unless s.closed?
      false
    end

    def self.requires_installation?(installer_prefix_dir, installer_path, component_path_part = '', type = :jar)
      return false unless File.exist?(installer_path)
      install_dir = get_install_dir_from_installer(installer_path, type)
      # puts "install_dir is #{install_dir}"
      path_to_check = "#{installer_prefix_dir}/#{install_dir}/#{component_path_part}"
      # puts "path_to_check is #{path_to_check}"
      !(Dir.exist?(path_to_check) || File.exist?(path_to_check))
    end

    def self.wait_until_port_is_open(port, timeout = 120, ip = '127.0.0.1', continue_exec = nil)
      time_begin = Time.now # Current time
      # puts ">> wait_until_port_is_open IP=#{ip}:#{port} timeout=#{timeout}"
      Timeout.timeout(timeout, DynatraceTimeout) do
        sleep(1) until port_is_open?(ip, port)
        time_end = Time.now # Current time
        diff = (time_end - time_begin).ceil
        # puts ">> wait_until_port_is_open - waited=#{diff} seconds"
      end
    rescue DynatraceTimeout
      if continue_exec.nil?
        raise DynatraceNotReady.new("#{ip}:#{port}", timeout)
      end
    end

    def self.wait_until_rest_endpoint_is_ready!(endpoint, timeout = 180)
      Timeout.timeout(timeout, DynatraceTimeout) do
        begin
          open(endpoint, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
        rescue SocketError,
               Errno::ECONNREFUSED,
               Errno::ECONNRESET,
               Errno::ENETUNREACH,
               Timeout::Error,
               OpenURI::HTTPError => e
          return if e.message =~ /^(401|403)/

          sleep(1)
          retry
        end
      end
    rescue DynatraceTimeout
      raise DynatraceNotReady.new(endpoint, timeout)
    end

    # def self.stop_processes(proc_pattern, proc_user, platform_family, timeout = 15, signal = 'TERM')
    #   pids = find_pids(proc_pattern, proc_user, platform_family)
    #   # puts "Process(es) to kill: #{pids}"
    #   killed = false
    #   unless pids.empty?
    #     until pids.empty?
    #       begin
    #         Process.kill signal, *pids
    #         break
    #       rescue Errno::ESRCH
    #         # The process could have terminated by itself. Retry to find processes matching search pattern.
    #         # puts "No such process(es): #{pids}. Retrying search pattern..."
    #         pids = find_pids(proc_pattern, proc_user, platform_family)
    #       end
    #     end
    #     begin
    #       Timeout.timeout(timeout, DynatraceTimeout) do
    #         loop do
    #           pids = find_pids(proc_pattern, proc_user, platform_family)
    #           if pids.empty?
    #             # puts "Terminated process(es)"
    #             killed = true
    #             break
    #           end
    #           # puts "Waiting for process(es) #{pids} to finish"
    #           sleep 1
    #         end
    #       end
    #     rescue DynatraceTimeout
    #       raise "Process(es) #{pids} did not stop"
    #     end
    #   end
    #   killed
    # end
    #
    # # private_class_method
    # def self.find_pids(pattern, user, platform_family)
    #   pids = []
    #   raise 'ERROR: Unsupported platform' unless %w(debian fedora rhel).include? platform_family
    #
    #   pgrep_pattern_opt = !pattern.nil? ? "-f \"#{pattern}\"" : ''
    #   pgrep_user_opt = !user.nil? ? "-u #{user}" : ''
    #   search_processes_cmd = "pgrep #{pgrep_pattern_opt} #{pgrep_user_opt}"
    #
    #   #################################################################
    #   # code below doesn't work if workstation is on windows
    #   #        %x[#{search_processes_cmd}].each_line do |pid_str|
    #   #          if !pid_str.empty?
    #   #            puts 'pid:' + pid_str
    #   #            pids << pid_str.to_i
    #   #          end
    #   #          return pids
    #   #        end
    #   # this part working and fixes code above
    #   pid_str = `#{search_processes_cmd}`
    #   unless pid_str.empty?
    #     text = []
    #     text << pid_str.lines.map(&:chomp)
    #     text.each do |x|
    #       x.each do |y|
    #         pids << y.to_i
    #       end
    #     end
    #   end
    #   #################################################################
    #
    #   pids
    # end

    private_class_method :port_is_open?, :find_pids, :get_version_from_manifest
  end
end
