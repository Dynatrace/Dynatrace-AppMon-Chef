#
# Cookbook Name:: dynatrace
# Resources:: copy_or_download_installer
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :installer_file_name,  :kind_of => String, :default => nil
attribute :installer_file_url,   :kind_of => String, :default => nil
attribute :installer_prefix_dir, :kind_of => String, :default => nil
attribute :dynatrace_owner,      :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,      :kind_of => String, :default => 'dynatrace'
