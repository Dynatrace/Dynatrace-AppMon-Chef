#
# Cookbook Name:: dynatrace
# Recipes:: host_agent_uninstall
#
# Copyright 2016, Dynatrace
#
name = 'Host Agent'

unless platform_family?('debian', 'fedora', 'rhel')
  raise 'Unsupported platform family.'
end

installer_prefix_dir = node['dynatrace']['host_agent']['installer']['prefix_dir']
installer_cache_dir = "#{Chef::Config['file_cache_path']}/host_agent"
service_name = 'dynaTraceHostagent'

service name.to_s do
  service_name service_name
  supports     :status => true, :stop => true
  action       [:stop, :disable]
end

directory "Delete the installer cache directory #{installer_cache_dir}" do
  path installer_cache_dir
  recursive true
  action :delete
end

# NOTE: this may also delete files from other packages!
dir2del = installer_prefix_dir + '/dynatrace'
dynatrace_delete_directory_by_link dir2del.to_s do
  link2delete dir2del
end
