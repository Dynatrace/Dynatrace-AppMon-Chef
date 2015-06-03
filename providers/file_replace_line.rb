#
# Cookbook Name:: dynatrace
# Providers:: file_replace_line
#
# Copyright 2015, Dynatrace
#

require 'fileutils'

action :run do
  FileUtils.touch(new_resource.path) if !::File.exist?(new_resource.path)
  file = Chef::Util::FileEdit.new(new_resource.path)
  file.search_file_replace(/#{new_resource.regex}/, new_resource.replace)
  file.write_file
end
