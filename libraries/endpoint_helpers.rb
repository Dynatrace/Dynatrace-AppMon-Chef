#
# Cookbook Name:: dynatrace
# Libraries:: endpoint_helpers
#
# Copyright 2016, Dynatrace
#

require 'net/http'
require 'open-uri'
require 'socket'
require 'timeout'

module Dynatrace
  # Helper methods used to test a service endpoint
  module EndpointHelpers
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

    private_class_method :port_is_open?
  end
end
