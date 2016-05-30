#
# Cookbook Name:: dynatrace
# Recipes:: collector
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::upgrade_system'
include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Collector'

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
    node.set[:dynatrace][:collector][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'collector', type=:jar)
  end
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
  only_if { node[:dynatrace][:collector][:installation][:is_required] }
end

dynatrace_run_jar_installer "#{name}" do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:collector][:installation][:is_required] }
end

dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables({ :agent_port => agent_port, :server_hostname => server_hostname, :server_port => server_port, :jvm_xmx => collector_jvm_xmx, :jvm_xms => collector_jvm_xms, :jvm_perm_size => collector_jvm_perm_size, :jvm_max_perm_size => collector_jvm_max_perm_size })
  notifies             :restart, "service[#{name}]", :immediately
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:start, :enable]
end

ruby_block "Waiting for port #{agent_port} to become available" do
  block do
    Dynatrace::Helpers.wait_until_port_is_open(agent_port)
  end
end
