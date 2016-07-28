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

module Dynatrace
  module Helpers
    class DynatraceTimeout < Timeout::Error; end

    class DynatraceNotReady < StandardError
      def initialize(endpoint, timeout)
        super <<-EOH
The Dynatrace Server at `#{endpoint}' did not become ready within #{timeout} seconds.
Possibly, Dynatrace has failed to start. Please check your Dynatrace Server log files.
EOH
      end
    end

    def self.read_file2out(description, file)
      puts "#{description}"
      File.readlines("#{file}").each do |line|
        puts line
      end
    end
    
    def self.file_append_or_replace_line(path, regex, line)
      FileUtils.touch(path) if !::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      if not file.insert_line_if_no_match(/#{regex}/, line)
        file.search_file_replace_line(/#{regex}/, line)
      end
      file.write_file
    end

    # NOTE: this method loads whole content of a file into memory
    # before doing the pattern substitution
    def self.file_replace(path, regex, subst)
      data = File.read(path, mode: "r+")
      data.gsub!(/#{regex}/, subst)
      File.open(path, "w") do |f|
        f.write(data)
      end
    end

    def self.file_replace_line(path, regex, replace)
      FileUtils.touch(path) if !::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      file.search_file_replace_line(/#{regex}/, replace)
      file.write_file
    end

    def self.get_install_dir_from_installer_msi(installer_path)
      #TODO
      # installer_path must be set to something like this:
      #           C:\chef\cache\easy_travel\easy_travel_install.log
      # we have to read this file and find following properties:
      #  Property(S): APPDIR = C:\Program Files\dynaTrace\easyTravel (x64)\
      #  Property(S): resources_DIR = C:\Program Files\dynaTrace\easyTravel (x64)\resources\
      #  Property(S): weblauncher_DIR = C:\Program Files\dynaTrace\easyTravel (x64)\weblauncher\

      app_DIR = nil
      resources_DIR = nil
      weblauncher_DIR = nil
      targetdir_pattern = 'TARGETDIR ='.encode("iso-8859-1").force_encoding("utf-8")
      property_pattern = 'Property(S): '.encode("iso-8859-1").force_encoding("utf-8")
      File.open("#{installer_path}", "rb").each do |line|
        line0 = line[0, 48]
        if !line0.nil?
          puts line0 + ' : ' + targetdir_pattern.length.to_s + ' : ' + line
          if line0.start_with?(property_pattern)
            if line0.start_with?(targetdir_pattern)
              app_DIR = line
              puts "!!!! app_DIR=#{app_DIR}"
            end
            if line0.start_with?('resources_DIR =')
              resources_DIR = line
              puts "resources_DIR=#{resources_DIR}"
            end
          end
        end
      end
      
      puts '!!!! targetdir_pattern.length=' + targetdir_pattern.length.to_s + ' : ' + targetdir_pattern + ' : ' + targetdir_pattern[0, targetdir_pattern.length]
      if !app_DIR.nil?
        puts "!!!! app_DIR=#{app_DIR}"
      else
        puts "!!!! app_DIR=nil !!!"
      end
    
      if !resources_DIR.nil?
        puts "resources_DIR=#{resources_DIR}"
      end
    
      if !weblauncher_DIR.nil?
        puts "weblauncher_DIR=#{weblauncher_DIR}"
      end
      
      app_DIR
    end
    
    def self.get_install_dir_from_installer_tar(installer_path)
      # extract the dynatrace.x.y.z directory name from the contained installer shell script
      install_dir = Mixlib::ShellOut.new("tar -xf #{installer_path} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2", :cwd => File.dirname(installer_path)).run_command.stdout.strip
      install_dir
    end
    
    def self.get_install_dir_from_installer_jar(installer_path)
      # extract the Manifest file
      cwd = File.dirname(installer_path)
      Mixlib::ShellOut.new("jar -xf #{installer_path} META-INF/MANIFEST.MF", :cwd => cwd).run_command

      prefix = nil
      ver_rev = '' # optional
      ver_maj= nil
      ver_min = nil
      File.open("#{cwd}/META-INF/MANIFEST.MF").each do |line|
        prefix = $1 if /prefix:\s*(\S+)/.match(line)
        break if prefix
        ver_maj = $1 if /version-major:\s*(\S+)/.match(line)
        ver_min = $1 if /version-minor:\s*(\S+)/.match(line)
        ver_rev = ".#{$1}" if /version-revision:\s*(\S+)/.match(line)
      end
      # Use a default prefix if prefix attribute not present in the Manifest file
      # The logic below is taken from the AbstractInstaller class in the Dynatrace jars
      install_dir = prefix ? prefix : "dynatrace-#{ver_maj}.#{ver_min}#{ver_rev}"

      # remove temporary directories
      Mixlib::ShellOut.new("rm -rf META-INF", :cwd => File.dirname(installer_path)).run_command
      
      install_dir
    end
    
    def self.get_install_dir_from_installer(installer_path, type=:jar)
      if type == :jar
        install_dir = get_install_dir_from_installer_jar(installer_path)
      end
      
      if type == :tar
        install_dir = get_install_dir_from_installer_tar(installer_path)
      end    
      
      if type == :msi
        install_dir = get_install_dir_from_installer_msi(installer_path)
      end        

      install_dir
    end

    def self.get_last_install_path(installer_prefix_dir)
      cmd = "find . -maxdepth 1 -name dynatrace-\\* -type d -printf \'%T@ %p\' | sort -k 1nr | cut -d\' \' -f2 | head -1 | xargs basename | xargs echo -n"
      shell = Mixlib::ShellOut.new(cmd, :cwd => installer_prefix_dir)
      shell.run_command

      return "#{installer_prefix_dir}/#{shell.stdout}"
    end

    private
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
            s.close if !s.closed?
          end
        end
      end

      s.close if !s.closed?
      return false
    end

    def self.requires_installation?(installer_prefix_dir, installer_path, component_path_part = '', type=:jar)
      return false if !File.exist?(installer_path)
      install_dir = get_install_dir_from_installer(installer_path, type)
  #puts "install_dir is #{install_dir}"
      path_to_check = "#{installer_prefix_dir}/#{install_dir}/#{component_path_part}"
  #puts "path_to_check is #{path_to_check}"
      return !(Dir.exist?(path_to_check) || File.exist?(path_to_check))
    end

    def self.wait_until_port_is_open(port, timeout = 120, ip = '127.0.0.1', continue_exec = nil)
      puts "!!!!! wait_until_port_is_open IP=#{ip}:#{port} timeout=#{timeout}"
        Timeout.timeout(timeout, DynatraceTimeout) do
      while !self.port_is_open?(ip, port) do
        sleep(1)
      end
    end
    rescue DynatraceTimeout
      if continue_exec.nil? 
        raise DynatraceNotReady.new("#{ip}:#{port}", timeout)
      else
        pyts "!!!!! ERROR:timeout! wait_until_port_is_open IP=#{ip}:#{port} timeout=#{timeout}"
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
    
    def self.stop_processes(proc_pattern, proc_user, platform_family, timeout = 15, signal = 'TERM')
      pids = self.find_pids(proc_pattern, proc_user, platform_family)
      killed = false
      if pids.size > 0
        Process.kill signal, *pids
        begin
          Timeout.timeout(timeout, DynatraceTimeout) do
            while (true)
              pids = self.find_pids(proc_pattern, proc_user, platform_family)
              if pids.size == 0
                #puts("Process(es) #{pids} terminated")
                killed = true
                break
              end
              #puts("Waiting for process(es) #{pids} to finish")
              sleep 1
            end            
          end
        rescue DynatraceTimeout
          raise "Process(es) #{pids} did not stop"
        end
      end
      return killed      
    end
    
    private
    def self.find_pids(pattern, user, platform_family)
      pids = Array.new
      if ['debian', 'fedora', 'rhel'].include? platform_family
        pgrep_pattern_opt = !pattern.nil? ? "-f \"#{pattern}\"" : ''
        pgrep_user_opt = !user.nil? ? "-u #{user}" : ''
        search_processes_cmd = "pgrep #{pgrep_pattern_opt} #{pgrep_user_opt}"

        #################################################################                
        # code below doesn't work if workstation is on windows
#        %x[#{search_processes_cmd}].each_line do |pidStr|
#          if !pidStr.empty?
#            puts 'pid:' + pidStr
#            pids << pidStr.to_i
#          end
#          return pids
#        end
        # this part working and fixes code above
        pidStr = %x[#{search_processes_cmd}]
        if !pidStr.empty?
          text = Array.new
          text << pidStr.lines.map(&:chomp)
          text.each {|x| 
            x.each {|y|
              pids << y.to_i 
            }
          }
        end
        #################################################################
                        
      else
        puts "ERROR: Unsupported platform"
      end
      return pids
    end
  end
end
