#
# Cookbook Name:: dynatrace
# Providers:: file_append_line
#
# Copyright 2015, Dynatrace
#

require 'fileutils'

action :run do
  FileUtils.touch(new_resource.path) if !::File.exist?(new_resource.path)
  file = Chef::Util::FileEdit.new(new_resource.path)
  file.insert_line_if_no_match(/#{new_resource.line}/, new_resource.line)
  file.write_file
end
