#
# Cookbook Name:: dynatrace
# Resources:: make_symlink
# Copyright 2016, Dynatrace
#

actions :run
default_action :run

attribute :archive,              :kind_of => String, :default => 'jar'
attribute :name,                 :kind_of => String, :default => nil
attribute :installer_prefix_dir, :kind_of => String, :default => nil
attribute :installer_path,       :kind_of => String, :default => nil
attribute :target_dir,           :kind_of => String, :default => nil
attribute :target_symlink,       :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_owner,      :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,      :kind_of => String, :default => 'dynatrace'
