#
# Cookbook Name:: dynatrace
# Libraries:: file_helpers
#
# Copyright 2016, Dynatrace
#

require 'fileutils'

module Dynatrace
  # File helper methods
  module FileHelpers
    def self.file_append_or_replace_line(path, regex, line)
      file = Chef::Util::FileEdit.new(path)
      unless file.insert_line_if_no_match(/#{regex}/, line)
        file.search_file_replace_line(/#{regex}/, line)
      end
      file.write_file
    end

    # NOTE: this method loads whole content of a file into memory
    # before doing the pattern substitution
    def self.file_cond_append_or_replace(path, regex, subst, cond_regex = nil)
      cond_regex = subst if cond_regex.nil?
      data = File.read(path, :mode => 'r+')
      return false if data =~ /#{cond_regex}/
      if data =~ /#{regex}/
        data.gsub!(/#{regex}/, subst)
      else
        # Remove any trailing new lines before appending our line
        data = data.chomp('') << "\n" << subst
      end
      File.open(path, 'w') do |f|
        f.write(data)
      end
      true
    end

    def self.file_replace_line(path, regex, replace)
      FileUtils.touch(path) unless ::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      updated = file.search_file_replace_line(/#{regex}/, replace)
      file.write_file
      updated
    end

    def self.file_cond_replace_line(path, regex, replace, cond_regex = nil)
      cond_regex = replace if cond_regex.nil?
      FileUtils.touch(path) unless ::File.exist?(path)
      File.open(path, 'r') do |f|
        f.each_line do |line|
          if (line =~ /#{cond_regex}/)
            puts "matched line '#{line}'"
            return false
            else
            puts "non matched line '#{line}' '#{cond_regex}'"
          end
        end
      end

      file = Chef::Util::FileEdit.new(path)
      file.search_file_replace_line(/#{regex}/, replace)
      file.write_file
      true
    end
  end
end
