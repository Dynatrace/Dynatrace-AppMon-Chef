#
# Cookbook Name:: dynatrace
# Recipes:: wsagent_package_uninstall
#
# Copyright 2016, Dynatrace
#

require 'json'

name = 'Dynatrace WebServer Agent package uninstall'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir']
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"

  service = 'dynaTraceWebServerAgent'
elsif platform_family?('windows')
  raise 'Unsupported platform family.'
end

service name.to_s do
  service_name service
  supports     :status => true
  action [:stop, :disable]
end

directory 'Delete the installer cache directory' do
  path   installer_cache_dir
  recursive true
  action :delete
end

# NOTE: this may also delete files from other packages!
link2del = installer_prefix_dir + '/dynatrace'
dynatrace_delete_directory_by_link link2del.to_s do
  link2delete link2del
end
