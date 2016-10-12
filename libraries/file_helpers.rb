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

    def self.file_replace_line(path, regex, replace)
      FileUtils.touch(path) unless ::File.exist?(path)
      file = Chef::Util::FileEdit.new(path)
      file.search_file_replace_line(/#{regex}/, replace)
      file.write_file
    end
  end
end
