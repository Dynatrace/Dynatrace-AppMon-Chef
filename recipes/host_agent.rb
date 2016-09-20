#
# Cookbook Name:: dynatrace
# Recipes:: host_agent
#
# Copyright 2016, Dynatrace
#

name = 'Host Agent'
include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::dynatrace_user'

if platform_family?('debian', 'fedora', 'rhel') #platform_family?('rhel') and node_kernel_machine == 'x86_64'
  installer_prefix_dir = node['dynatrace']['host_agent']['installer']['prefix_dir']
  installer_file_url   = node['dynatrace']['host_agent']['installer']['file_url']
  installer_file_name  = node['dynatrace']['host_agent']['installer']['file_name']
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/host_agent"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  service_name = 'dynaTraceHostagent'
else
  raise "Unsupported platform family."
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
    kernel = node['host_agent']['installer']['bitsize']
    node.set[:dynatrace][:host_agent][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, "agent/lib#{kernel}/dthostagent", type=:tar)
  end
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
end

dynatrace_run_tar_installer "#{name}" do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
end


host_agent_name = node['dynatrace']['host_agent']['host_agent_name']
host_agent_collector = node['dynatrace']['host_agent']['collector']
config_path = "#{installer_prefix_dir}/dynatrace/agent/conf/dthostagent.ini"
ruby_block "Setting the name and collector address in #{config_path}" do
  block do
    Dynatrace::Helpers.file_replace_line(config_path, '^Name', "Name #{host_agent_name}")
    Dynatrace::Helpers.file_replace_line(config_path, '^Server', "Server #{host_agent_collector}")
  end
end

init_scripts = [service_name]
dynatrace_configure_init_scripts "#{name}" do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
end

service name do
  service_name service_name
  supports :status => true
  action [ :enable, :restart ]
end
