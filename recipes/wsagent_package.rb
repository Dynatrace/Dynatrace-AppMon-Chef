#
# Cookbook Name:: dynatrace
# Recipes:: wsagent_package
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace WebServer Agent'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['wsagent_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['wsagent_package']['linux']['installer']['file_url']
  installer_path       = "#{installer_prefix_dir}/#{installer_file_name}"
  
  init_scripts = services = ['dynaTraceWebServerAgent']
else
# unsupported
end

dynatrace_copy_or_download_installer "#{name}" do
  installer_prefix_dir installer_prefix_dir
  installer_file_name  installer_file_name
  installer_file_url   installer_file_url  
end

ruby_block "#{name}" do
  block do
    node.set[:dynatrace][:wsagent_package][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'agent', type=:tar)
  end
end

dynatrace_stop_services "#{name}" do
  services services
  only_if { node[:dynatrace][:wsagent_package][:installation][:is_required] }
end

dynatrace_run_tar_installer "#{name}" do
  installer_prefix_dir installer_prefix_dir
  installer_path       installer_path
  only_if { node[:dynatrace][:wsagent_package][:installation][:is_required] }
end

template "Configure and copy the #{name}'s 'dtwsagent.ini' file" do
  source 'wsagent_package/dtwsagent.ini.erb'
  path   "#{installer_prefix_dir}/dynatrace/agent/conf/dtwsagent.ini"
  owner  'dynatrace'
  group  'dynatrace'
  mode   '0644'
  variables({
    :agent_name => node['dynatrace']['wsagent_package']['agent_name'],
    :collector_hostname => node['dynatrace']['wsagent_package']['collector_hostname'],
    :collector_port => node['dynatrace']['wsagent_package']['collector_port']
  })
  action :create
end

dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
end

dynatrace_start_services "#{name}" do
  services services
end
