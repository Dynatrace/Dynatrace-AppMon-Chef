#
# Cookbook Name:: dynatrace
# Resources:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :file_name, :kind_of => String, :default => nil
attribute :file_url,  :kind_of => String, :default => nil
attribute :path,      :kind_of => String, :default => nil
