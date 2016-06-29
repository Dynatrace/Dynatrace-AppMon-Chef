#
# Cookbook Name:: dynatrace
# Resources:: run_jar_installer
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,                 :kind_of => String, :default => nil
attribute :installer_prefix_dir, :kind_of => String, :default => nil
attribute :installer_path,       :kind_of => String, :default => nil
attribute :target_dir,           :kind_of => String, :default => nil

#sometimes we need to find real installer path in cache, to allow this set find_installer_folder not empty and not nil e.g. "true"
attribute :find_installer_folder,:kind_of => String, :default => nil
#real installer path in cache can be different e.g. easy_travel instead of easytravel; used only when find_installer_folder is not nil
attribute :cache_path,           :kind_of => String, :default => nil

attribute :target_symlink,       :kind_of => String, :default => 'dynatrace'
attribute :jar_input_sequence,   :kind_of => String, :default => nil
attribute :dynatrace_owner,      :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,      :kind_of => String, :default => 'dynatrace'
