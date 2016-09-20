#
# Cookbook Name:: dynatrace
# Recipes:: collector_uninstall
#
# Copyright 2016, Dynatrace
#
include_recipe 'dynatrace::node_info'
include_recipe 'java'

name = 'Uninstall Dynatrace Collector'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['collector']['linux']['installer']['prefix_dir']
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  service = 'dynaTraceCollector'
else
  raise "Unsupported platform family."
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:stop, :disable]
end

directory "Delete the installer cache directory #{installer_cache_dir}" do
  path   installer_cache_dir
  recursive true
  action :delete
end

# NOTE: this may also delete files from other packages!
link2del = installer_prefix_dir + '/dynatrace'
dynatrace_delete_directory_by_link "#{link2del}" do
  link2delete link2del
end

