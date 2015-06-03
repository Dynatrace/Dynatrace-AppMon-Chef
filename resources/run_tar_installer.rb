#
# Cookbook Name:: dynatrace
# Resources:: run_tar_installer
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,                 :kind_of => String, :default => nil
attribute :installer_prefix_dir, :kind_of => String, :default => nil
attribute :installer_path,       :kind_of => String, :default => nil
