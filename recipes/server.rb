#
# Cookbook Name:: dynatrace
# Recipes:: server
#
# Copyright 2015, Dynatrace
#

require 'json'
require 'net/https'

include_recipe 'dynatrace::prerequisites'
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
external_hostname = node['dynatrace']['server']['externalhostname']

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']
easyTravelProfile = node['dynatrace']['server']['linux']['installer']['easyTravelProfile']
  
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

ruby_block "Check if #{name} already installed #{installer_prefix_dir} #{installer_path}" do
  block do
    node.set[:dynatrace][:server][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'server', type=:jar)
  end
end

fresh_installer_action = "#{name} installer changed"
dynatrace_copy_or_download_file "#{name}" do
  file_name       installer_file_name
  file_url        installer_file_url  
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
  notifies :run, "ruby_block[#{fresh_installer_action}]", :immediately
end

ruby_block "#{fresh_installer_action}" do
  block do
    node.set[:dynatrace][:server][:installation][:is_required] = true
  end
  action :nothing
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

service "Stop service #{name}" do
  service_name service
  supports     :status => true
  action       [:stop, :enable]
  ignore_failure true                 #TODO added because of service[Stop service Dynatrace Server]: Service is not known to chkconfig.
end

profiles = '/opt/dynatrace/server/conf/profiles/'
directory "Create profiles directory #{profiles}" do
  path      profiles
  owner     dynatrace_owner unless ::File.exist?(profiles)
  group     dynatrace_group unless ::File.exist?(profiles)
  recursive true
  action    :create
end

dynatrace_copy_or_download_file "easyTravel.profile.xml" do
  file_name       'easyTravel.profile.xml'
  file_url        easyTravelProfile  
  path            "#{profiles}easyTravel.profile.xml"
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
end

dtserver_ini_file = "#{installer_prefix_dir}/dynatrace/dtserver.ini"
dtfrontendserver_ini_file  = "#{installer_prefix_dir}/dynatrace/dtfrontendserver.ini"
server_config_xml_file = "#{installer_prefix_dir}/dynatrace/server/conf/server.config.xml"

dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :collector_port => collector_port })
#  notifies             :restart, "service[#{name}]", :immediately                            #removed because have to modify ini files - see below
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:restart, :enable]
  ignore_failure true
end

ruby_block "Test ini files memory sizing=#{sizing}" do
  block do
    #wait for update ini files
    puts '>> Wait for update ini files on clean installation'
    sleep(30)
  end
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

dynatrace_configure_ini_files "#{name} sizing=#{sizing}" do
  installer_prefix_dir installer_prefix_dir
  ini_files            ini_files
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :memory => sizing })
end

ruby_block "Modify server configuration #{server_config_xml_file}" do
  block do
    Dynatrace::Helpers.file_replace("#{server_config_xml_file}", " externalhostname=\"[a-zA-Z0-9._-]*\"", " externalhostname=\"#{external_hostname}\"")
  end

end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:restart, :enable]
  ignore_failure false
end

ruby_block "Display ini files after applying memory sizing=#{sizing}" do
  block do
    Dynatrace::Helpers.read_file2out(">> Content of ini file #{dtserver_ini_file}", dtserver_ini_file)
    Dynatrace::Helpers.read_file2out(">> Content of ini file #{dtfrontendserver_ini_file} file", dtfrontendserver_ini_file)
  end
end

[collector_port, 2021, 6699, 8021, 9911].each do | port |
  ruby_block "Waiting for port #{port} to become available" do
    block do
      # Set a longer timeout due to the time to open the collector port
      # (see log "[SelfMonitoringLauncher] Waiting for self-monitoring Collector startup (max: 90 seconds)")
      Dynatrace::Helpers.wait_until_port_is_open(port, 300)     #wait 5 minutes
    end
    ignore_failure false
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
