#
# Cookbook Name:: dynatrace
# Resource:: uninstall_package
#
# Copyright:: Copyright 2016, Dynatrace
#

actions :run
default_action :run

property :name, String, :name_property => true
property :installation_path, String
property :installer_cache_path, String
property :service_name, String, :default => nil

action :run do
  include_recipe 'dynatrace::node_info'

  delete_cache_path_action = "Delete the installer cache directory #{installer_cache_path}"
  delete_install_path_action = "Delete installation dir by link ''#{installation_path}''"
  service service_name do
    action [:stop, :disable]
    # Defer directory deletion to the end of run list
    notifies :delete, "directory[#{delete_cache_path_action}]"
    notifies :run, "dynatrace_delete_directory_by_link[#{delete_install_path_action}]"
    not_if { service_name.to_s.empty? }
  end

  directory delete_cache_path_action do
    path installer_cache_path
    recursive true
    action :nothing
  end

  dynatrace_delete_directory_by_link delete_install_path_action do
    link2delete installation_path
    action :nothing
  end
end
