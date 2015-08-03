#
# Cookbook Name:: dynatrace
# Recipes:: server
#
# Copyright 2015, Dynatrace
#

require 'json'

include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Server'

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

  init_scripts = ['dynaTraceBackendServer', 'dynaTraceFrontendServer', 'dynaTraceServer']
  services     = ['dynaTraceServer']
else
  # Unsupported
end


directory "Create the installer cache directory" do
  path   installer_cache_dir
  action :create
end

dynatrace_copy_or_download_file "#{name}" do
  file_name       installer_file_name
  file_url        installer_file_url  
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
end

ruby_block "#{name}" do
  block do
    node.set[:dynatrace][:server][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'server', type=:jar)
  end
end

dynatrace_stop_services "#{name}" do
  services services
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

dynatrace_run_jar_installer "#{name}" do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :collector_port => collector_port })
end

dynatrace_start_services "#{name}" do
  services services
end

[2021, collector_port, 6699, 8020, 8021].each do | port |
  dynatrace_wait_until_port_is_open  "Waiting for port #{port}" do
    port "#{port}"
  end
end

dynatrace_wait_until_rest_endpoint_is_ready "Waiting for endpoint '/rest/management/pwhconnection/config'" do
  endpoint 'http://localhost:8020/rest/management/pwhconnection/config'
end

http_request "Establish the #{name}'s Performance Warehouse connection" do
  url 'http://localhost:8020/rest/management/pwhconnection/config'
  headers({ 'Authorization' => "Basic #{Base64.encode64('admin:admin')}", 'Content-Type' => 'application/json' })
  message({ :host => "#{pwh_connection_hostname}", :port => "#{pwh_connection_port}", :dbms => "#{pwh_connection_dbms}", :dbname => "#{pwh_connection_database}", :user => "#{pwh_connection_username}", :password => "#{pwh_connection_password}", :usessl => false, :useurl => false, :url => nil }.to_json)
  ignore_failure true
  action :put
  only_if { do_pwh_connection }
end
