#
# Cookbook Name:: dynatrace
# Recipes:: server
#
# Copyright 2015-2016, Dynatrace
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

external_hostname = node['dynatrace']['server']['externalhostname']

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

raise 'Unsupported platform family.' unless platform_family?('debian', 'fedora', 'rhel')

installer_prefix_dir = node['dynatrace']['server']['linux']['installer']['prefix_dir']
installer_file_name  = node['dynatrace']['server']['linux']['installer']['file_name']
installer_file_url   = node['dynatrace']['server']['linux']['installer']['file_url']

installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

service      = 'dynaTraceServer'
ini_files    = ['dtserver.ini', 'dtfrontendserver.ini']
init_scripts = ['dynaTraceBackendServer', 'dynaTraceFrontendServer', service]

directory 'Create the installer cache directory' do
  path   installer_cache_dir
  action :create
end

ruby_block "Check if #{name} already installed #{installer_prefix_dir} #{installer_path}" do
  block do
    node.set[:dynatrace][:server][:installation][:is_required] = Dynatrace::PackageHelpers.requires_installation?(installer_prefix_dir, installer_path, 'server', type = :jar)
  end
end

fresh_installer_action = "#{name} installer changed"
dynatrace_copy_or_download_file name.to_s do
  file_name       installer_file_name
  file_url        installer_file_url
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
  notifies :run, "ruby_block[#{fresh_installer_action}]", :immediately
end

ruby_block fresh_installer_action.to_s do
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

dynatrace_run_jar_installer name.to_s do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

service "Stop service #{name}" do
  service_name service
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports :status => true
  action [:stop]
  ignore_failure true # fails on Debian 7.8 on clean installation
end

server_config_xml_file = "#{installer_prefix_dir}/dynatrace/server/conf/server.config.xml"

dynatrace_configure_init_scripts name.to_s do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables(:collector_port => collector_port)
end

dynatrace_configure_ini_files "#{name} sizing=#{sizing}" do
  installer_prefix_dir installer_prefix_dir
  ini_files            ini_files
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables(:memory => sizing)
end

service name.to_s do
  service_name service
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports     :status => true
  action       [:start]
end

ruby_block "Wait to set external host name in #{server_config_xml_file}" do
  # TODO: there should be a REST API to check if server is initialized
  block do
    begin
      Timeout.timeout(60) do
        loop do
          break if ::File.exist? server_config_xml_file
          Chef::Log.info "Waiting for file #{server_config_xml_file} to appear..."
          sleep 1
        end
      end
    rescue Timeout::Error
      raise "#{server_config_xml_file} did not appear"
    end
    # Leave some extra time for the server to avoid file read/write hazards
    sleep 10
  end
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

ruby_block "Set external host name in #{server_config_xml_file}" do
  block do
    Chef::Log.info "External host name is: #{external_hostname}"
    Dynatrace::FileHelpers.file_replace(server_config_xml_file.to_s, ' externalhostname="[a-zA-Z0-9._-]*"', " externalhostname=\"#{external_hostname}\"")
  end
end

service name.to_s do
  service_name service
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports     :status => true
  action       [:restart, :enable]
end

[collector_port, 2021, 8021, 9911].each do |port|
  ruby_block "Waiting for port #{port} to become available" do
    block do
      # Set a longer timeout due to the time to open the collector port
      # (see log "[SelfMonitoringLauncher] Waiting for self-monitoring Collector startup (max: 90 seconds)")
      Dynatrace::EndpointHelpers.wait_until_port_is_open(port, 300) # wait 5 minutes
    end
  end
end
