#
# Cookbook Name:: dynatrace
# Recipes:: server
#
# Copyright 2015, Dynatrace
#

require 'json'
require 'net/https'

include_recipe 'dynatrace::helpers'
include_recipe 'dynatrace::upgrade_system'
include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Server'

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
  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

dynatrace_configure_ini_files "#{name}" do
  installer_prefix_dir installer_prefix_dir
  ini_files            ini_files
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :memory => sizing })
end

dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :collector_port => collector_port })
  notifies             :restart, "service[#{name}]", :immediately
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:start, :enable]
end

[collector_port, 2021, 6699, 8021, 9911].each do | port |
  ruby_block "Waiting for port #{port} to become available" do
    block do
      # Set a longer timeout due to the time to open the collector port
      # (see log "[SelfMonitoringLauncher] Waiting for self-monitoring Collector startup (max: 90 seconds)")
      Dynatrace::Helpers.wait_until_port_is_open(port, 210)
    end
  end
end

ruby_block "Waiting for endpoint '/rest/management/pwhconnection/config'" do
  block do
    Dynatrace::Helpers.wait_until_rest_endpoint_is_ready!('https://localhost:8021/rest/management/pwhconnection/config')
  end
  only_if { do_pwh_connection }
end

ruby_block "Establish the #{name}'s Performance Warehouse connection" do
  block do
    uri = URI('http://localhost:8021/rest/management/pwhconnection/config')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(uri, {'Accept' => 'application/json', 'Content-Type' => 'application/json'})
    request.basic_auth('admin', 'admin')
    request.body = { :host => "#{pwh_connection_hostname}", :port => "#{pwh_connection_port}", :dbms => "#{pwh_connection_dbms}", :dbname => "#{pwh_connection_database}", :user => "#{pwh_connection_username}", :password => "#{pwh_connection_password}", :usessl => false, :useurl => false, :url => nil }.to_json

    http.request(request)
  end
  only_if { do_pwh_connection }
end
