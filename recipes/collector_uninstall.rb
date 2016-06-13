#
# Cookbook Name:: dynatrace
# Recipes:: collector
#
# Copyright 2015, Dynatrace
#
include_recipe 'dynatrace::node_info'
include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'

name = 'Uninstall Dynatrace Collector'

installer_bitsize = node['dynatrace']['collector']['installer']['bitsize']

agent_port = node['dynatrace']['collector']['agent']['port']

server_hostname = node['dynatrace']['collector']['server']['hostname']
server_port     = node['dynatrace']['collector']['server']['port']

collector_jvm_xmx           = node['dynatrace']['collector']['jvm']['xmx']
collector_jvm_xms           = node['dynatrace']['collector']['jvm']['xms']
collector_jvm_perm_size     = node['dynatrace']['collector']['jvm']['perm_size']
collector_jvm_max_perm_size = node['dynatrace']['collector']['jvm']['max_perm_size']

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['collector']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['collector']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['collector']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  service = 'dynaTraceCollector'
  init_scripts = [service]
else
  # Unsupported
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

link2del = installer_prefix_dir + '/dynatrace'
dynatrace_delete_directory_by_link "#{link2del}" do
  link2delete link2del
end

#directory "Delete the installation directory #{link2del}" do
#  path      link2del
#  recursive true
#  action    :delete
#end
