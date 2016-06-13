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

    def self.file_append_or_replace_line(path, regex, line)
      FileUtils.touch(path) if !::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      if not file.insert_line_if_no_match(/#{regex}/, line)
        file.search_file_replace_line(/#{regex}/, line)
      end
      file.write_file
    end

    def self.file_replace_line(path, regex, replace)
      FileUtils.touch(path) if !::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      file.search_file_replace(/#{regex}/, replace)
      file.write_file
    end

    def self.get_install_dir_from_installer(installer_path, type=:jar)
      if type == :jar
        # extract an init script (includes reference to the dynatrace-x.y.z dir)
        init_script = Mixlib::ShellOut.new("jar -tf #{installer_path} | grep -e 'init.d' | tail -n 1").run_command.stdout.strip
        Mixlib::ShellOut.new("jar -xf #{installer_path} #{init_script}", :cwd => File.dirname(installer_path)).run_command

        # extract the dynatrace-x.y.z directory name from the init script
        install_dir = Mixlib::ShellOut.new("grep -e 'DT_HOME=' #{init_script} | cut -d'=' -f2 | xargs basename", :cwd => File.dirname(installer_path)).run_command.stdout.strip

        # remove temporary directories
        Mixlib::ShellOut.new("rm -rf init.d", :cwd => File.dirname(installer_path)).run_command
      elsif type == :tar
        # extract the dynatrace.x.y.z directory name from the contained installer shell script
        install_dir = Mixlib::ShellOut.new("tar -xf #{installer_path} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2").run_command.stdout.strip
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
      install_dir = get_install_dir_from_installer(installer_path, type)
      #puts "install_dir is #{install_dir}"
      path_to_check = "#{installer_prefix_dir}/#{install_dir}/#{component_path_part}"
      #puts "path_to_check is #{path_to_check}"
      return !(Dir.exist?(path_to_check) || File.exist?(path_to_check))
    end

    def self.wait_until_port_is_open(port, timeout = 120, ip = '127.0.0.1')
      Timeout.timeout(timeout, DynatraceTimeout) do
        while !self.port_is_open?(ip, port) do
          sleep(1)
        end
      end
    rescue DynatraceTimeout
      raise DynatraceNotReady.new("#{ip}:#{port}", timeout)
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
    
    def self.stop_processes(proc_pattern, platform_family, timeout = 15)
      pids = Array.new
      pids = self.find_pids(proc_pattern, platform_family)        
      killed = false
      if pids.size > 0
        Process.kill 'TERM', *pids
        begin
          Timeout.timeout(timeout, DynatraceTimeout) do
            while (true)
              pids = self.find_pids(proc_pattern, platform_family)
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
    def self.find_pids(pattern, platform_family)
      if ['debian', 'fedora', 'rhel'].include? platform_family
        pids = Array.new
        search_processes_cmd = "pgrep -f \"#{pattern}\""

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
                        
        return pids
      else
        raise "Unsupported platform"
      end
    end
  end
end
