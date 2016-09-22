#
# Cookbook Name:: dynatrace
# Recipes:: server_uninstall
#
# Copyright 2016, Dynatrace
#

require 'json'
require 'net/https'

include_recipe 'java'
include_recipe 'dynatrace::node_info'

name = 'Uninstall Dynatrace Server'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['server']['linux']['installer']['prefix_dir']
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"

  service = 'dynaTraceServer'
else
  raise 'Unsupported platform family.'
end

service name.to_s do
  service_name service
  supports     :status => true
  action       [:stop, :disable]
end

directory "Delete the installer cache directory #{installer_cache_dir}" do
  path installer_cache_dir
  recursive true
  action :delete
end

dir2del = installer_prefix_dir + '/dynatrace'
dynatrace_delete_directory_by_link dir2del.to_s do
  link2delete dir2del
end
