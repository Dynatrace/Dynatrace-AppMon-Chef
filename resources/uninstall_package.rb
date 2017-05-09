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
property :service_name, String, :default => ''

action :run do
  include_recipe 'dynatrace::node_info'

  delete_cache_path_action = "Delete the installer cache directory #{installer_cache_path}"
  delete_install_path_action = "Delete installation dir by link ''#{installation_path}''"

  unless service_name.to_s.empty?
    service service_name do
      # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
      supports :status => true
      action [:stop, :disable]
    end
  end

  ruby_block 'Defer directories deletion to the end of run list' do
    block {}
    notifies :delete, "directory[#{delete_cache_path_action}]"
    notifies :run, "dynatrace_delete_directory_by_link[#{delete_install_path_action}]"
  end

  directory delete_cache_path_action do
    path installer_cache_path
    recursive true
    action :nothing
  end

  dynatrace_delete_directory_by_link delete_install_path_action do
    # TODO: After "service stop" command exits some files may still be created...
    retries 2
    retry_delay 10
    link2delete installation_path
    action :nothing
  end
end
