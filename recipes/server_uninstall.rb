#
# Cookbook Name:: dynatrace
# Recipes:: server_uninstall
#
# Copyright 2015, Dynatrace
#

require 'json'
require 'net/https'

include_recipe 'dynatrace::upgrade_system'
include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'

name = 'Uninstall Dynatrace Server'

installer_bitsize = node['dynatrace']['server']['installer']['bitsize']

sizing = node['dynatrace']['server']['sizing']

collector_port = node['dynatrace']['server']['collector_port']

do_pwh_connection       = node['dynatrace']['server']['do_pwh_connection']
pwh_connection_hostname = node['dynatrace']['server']['pwh_connection']['hostname']
pwh_connection_port     = node['dynatrace']['server']['pwh_connection']['port']
pwh_connection_dbms     = node['dynatrace']['server']['pwh_connection']['dbms']
pwh_connection_database = node['dynatrace']['server']['pwh_connection']['database']
pwh_connection_username = node['dynatrace']['server']['pwh_connection']['username']
pwh_connection_password = node['dynatrace']['server']['pwh_connection']['password']

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['server']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['server']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['server']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  service      = 'dynaTraceServer'
  ini_files    = ['dtserver.ini', 'dtfrontendserver.ini']
  init_scripts = ['dynaTraceBackendServer', 'dynaTraceFrontendServer', service]
else
  # Unsupported
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:stop, :disable]
end

ruby_block "Stop any running instance of dynatrace service: dtserver" do
  block do
    Dynatrace::Helpers.stop_processes('dtserver', node['platform_family'])
  end
end

ruby_block "Stop any running instance of dynatrace service: dtfrontendserver" do
  block do
    Dynatrace::Helpers.stop_processes('dtfrontendserver', node['platform_family'])
  end
end

directory "Delete the installer cache directory #{installer_cache_dir}" do
  path   installer_cache_dir
  recursive true
  action :delete
end

dir2del = installer_prefix_dir + '/dynatrace'

#remove directory using symlink
cmd2exec = "rm -rf \"$(readlink #{dir2del})\""
execute "Remove directory content using symlink: #{cmd2exec}" do
  command cmd2exec
end

#remove symlink
cmd2exec = "rm -rf #{dir2del}"
execute "Remove symlink: #{cmd2exec}" do
  command cmd2exec
end

directory "Delete the installation directory #{dir2del}" do
  path      dir2del
  recursive true
  action    :delete
end

