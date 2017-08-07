#
# Cookbook Name:: dynatrace
# Recipes:: host_agent
#
# Copyright 2016, Dynatrace
#

name = 'Host Agent'
include_recipe 'dynatrace-appmon::prerequisites'
include_recipe 'dynatrace-appmon::java'
include_recipe 'dynatrace-appmon::dynatrace_user'
include_recipe 'line'

raise 'Unsupported platform family.' unless platform_family?('debian', 'fedora', 'rhel') # platform_family?('rhel') and node_kernel_machine == 'x86_64'

installer_prefix_dir = node['dynatrace']['host_agent']['linux']['installer']['prefix_dir']
installer_file_url   = node['dynatrace']['host_agent']['linux']['installer']['file_url']
installer_file_name  = node['dynatrace']['host_agent']['linux']['installer']['file_name']
installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

service_name = 'dynaTraceHostagent'

directory 'Create the installer cache directory' do
  path   installer_cache_dir
  action :create
end

ruby_block name.to_s do
  block do
    kernel = node['host_agent']['installer']['bitsize']
    node.set['dynatrace']['host_agent']['installation']['is_required'] = Dynatrace::PackageHelpers.requires_installation?(installer_prefix_dir, installer_path, "agent/lib#{kernel}/dthostagent", type = :tar)
    node.set['dynatrace']['host_agent']['config_changed'] = false
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
  not_if { node['dynatrace']['host_agent']['installation']['is_required'] }
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
end

dynatrace_run_tar_installer name.to_s do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node['dynatrace']['host_agent']['installation']['is_required'] }
end

config_changed_action = "#{name} config changed"
host_agent_name = node['dynatrace']['host_agent']['host_agent_name']
host_agent_collector = node['dynatrace']['host_agent']['collector']
config_path = "#{installer_prefix_dir}/dynatrace/agent/conf/dthostagent.ini"

lines_to_patch = []
agent_name_line = "Name #{host_agent_name}"
lines_to_patch << ['^Name\b', agent_name_line]
collector_addr_line = "Server #{host_agent_collector}"
lines_to_patch << ['^Server\b', collector_addr_line]

lines_to_patch.each do |patch_params|
  replace_or_add "Ensuring '#{patch_params[1]}' line is present in #{config_path}" do
    path config_path
    pattern patch_params[0]
    line patch_params[1]
    notifies :run, "ruby_block[#{config_changed_action}]", :immediately
  end
end

init_scripts = [service_name]
dynatrace_configure_init_scripts name.to_s do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  notifies :run, "ruby_block[#{config_changed_action}]", :immediately
end

# A trick to restart server only once on configuration change
ruby_block config_changed_action do
  block do
    node.set['dynatrace']['host_agent']['config_changed'] = true
  end
  action :nothing
end

ruby_block "Restart #{name}" do
  block {}
  notifies :restart, "service[#{name}]", :immediately
  only_if { node['dynatrace']['host_agent']['config_changed'] && !node['dynatrace']['host_agent']['installation']['is_required'] }
end

service name do
  service_name service_name
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports     :status => true
  action [:enable, :start]
end
