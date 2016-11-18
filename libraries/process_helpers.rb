#
# Cookbook Name:: dynatrace
# Libraries:: process_helpers
#
# Copyright 2016, Dynatrace
#

require 'fileutils'
require 'net/http'
require 'open-uri'
require 'socket'
require 'timeout'
require 'English' # $CHILD_STATUS.pid

module Dynatrace
  # Helper methods related to handling system processes
  module ProcessHelpers
    def self.stop_processes(proc_pattern, proc_user, platform_family, timeout = 15, signal = 'TERM')
      pids = find_pids(proc_pattern, proc_user, platform_family)
      # puts "Process(es) to kill: #{pids}"
      killed = false
      unless pids.empty?
        until pids.empty?
          begin
            Process.kill signal, *pids
            break
          rescue Errno::ESRCH
            # The process could have terminated by itself. Retry to find processes matching search pattern.
            # puts "No such process(es): #{pids}. Retrying search pattern..."
            pids = find_pids(proc_pattern, proc_user, platform_family)
          end
        end
        begin
          Timeout.timeout(timeout, Timeout::Error) do
            loop do
              pids = find_pids(proc_pattern, proc_user, platform_family)
              if pids.empty?
                # puts "Terminated process(es)"
                killed = true
                break
              end
              # puts "Waiting for process(es) #{pids} to finish"
              sleep 1
            end
          end
        rescue Timeout::Error
          raise "Process(es) #{pids} did not stop"
        end
      end
      killed
    end

    # private_class_method
    def self.find_pids(pattern, user, platform_family)
      pids = []
      raise 'ERROR: Unsupported platform' unless %w(debian fedora rhel).include? platform_family

      pgrep_pattern_opt = !pattern.nil? ? "-f \"#{pattern}\"" : ''
      pgrep_user_opt = !user.nil? ? "-u #{user}" : ''
      search_processes_cmd = "pgrep #{pgrep_pattern_opt} #{pgrep_user_opt}"

      #################################################################
      # code below doesn't work if workstation is on windows
      #        %x[#{search_processes_cmd}].each_line do |pid_str|
      #          if !pid_str.empty?
      #            puts 'pid:' + pid_str
      #            pids << pid_str.to_i
      #          end
      #          return pids
      #        end
      # this part working and fixes code above
      pid_str = `#{search_processes_cmd}`
      pgrep_pid = $CHILD_STATUS.pid
      unless pid_str.empty?
        text = []
        text << pid_str.lines.map(&:chomp)
        text.each do |x|
          x.each do |y|
            pids << y.to_i unless y.to_i == pgrep_pid
          end
        end
      end
      #################################################################

      pids
    end

    private_class_method :find_pids
  end
end
