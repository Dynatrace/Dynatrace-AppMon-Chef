#
# Cookbook Name:: dynatrace
# Recipes:: server
#
# Copyright 2015-2016, Dynatrace
#

require 'json'
require 'net/https'

include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::java'
include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Server'

installer_bitsize = node['dynatrace']['server']['installer']['bitsize']

sizing = node['dynatrace']['server']['sizing']

collector_port = node['dynatrace']['server']['collector_port']

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
    raise "The downloaded installer package would overwrite existing installation of the #{name}."
  end
  action :nothing
  not_if { node[:dynatrace][:server][:installation][:is_required] }
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
end

dynatrace_run_jar_installer name.to_s do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:server][:installation][:is_required] }
end

config_changed_action = "#{name} config changed"
dynatrace_configure_init_scripts name.to_s do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables(:collector_port => collector_port)
  notifies :run, "ruby_block[#{config_changed_action}]", :immediately
end

dynatrace_configure_ini_files "#{name} sizing=#{sizing}" do
  installer_prefix_dir installer_prefix_dir
  ini_files            ini_files
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables(:memory => sizing)
  notifies :run, "ruby_block[#{config_changed_action}]", :immediately
end

# A trick to not restart the server on first install
ruby_block config_changed_action do
  block {}
  notifies :restart, "service[#{name}]", :immediately
  action :nothing
  not_if { node[:dynatrace][:server][:installation][:is_required] }
end

service name.to_s do
  service_name service
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports     :status => true
  action       [:start, :enable]
end

max_boot_time = node['dynatrace']['server']['max_boot_time']
[collector_port, 2021, 8021, 9911].each do |port|
  ruby_block "Waiting for port #{port} to become available" do
    block do
      Dynatrace::EndpointHelpers.wait_until_port_is_open(port, max_boot_time)
    end
  end
end
