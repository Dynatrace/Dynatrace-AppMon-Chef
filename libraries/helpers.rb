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

    def self.file_append_line(path, line)
      FileUtils.touch(path) if !::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      file.insert_line_if_no_match(/#{line}/, line)
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
      path_to_check = "#{installer_prefix_dir}/#{install_dir}/#{component_path_part}"
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
  end
end
