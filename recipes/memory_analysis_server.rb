#
# Cookbook Name:: dynatrace
# Recipes:: memory_analysis_server
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Memory Analysis Server'

installer_bitsize = node['dynatrace']['memory_analysis_server']['installer']['bitsize']

server_port = node['dynatrace']['memory_analysis_server']['server']['port']

memory_analysis_server_jvm_xmx           = node['dynatrace']['memory_analysis_server']['jvm']['xmx']
memory_analysis_server_jvm_xms           = node['dynatrace']['memory_analysis_server']['jvm']['xms']
memory_analysis_server_jvm_perm_size     = node['dynatrace']['memory_analysis_server']['jvm']['perm_size']
memory_analysis_server_jvm_max_perm_size = node['dynatrace']['memory_analysis_server']['jvm']['max_perm_size']

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['memory_analysis_server']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['memory_analysis_server']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['memory_analysis_server']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  service = 'dynaTraceAnalysis'
  init_scripts = [service]
end

directory 'Create the installer cache directory' do
  path   installer_cache_dir
  action :create
end

dynatrace_copy_or_download_file name.to_s do
  file_name       installer_file_name
  file_url        installer_file_url
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
end

ruby_block name.to_s do
  block do
    node.set[:dynatrace][:memory_analysis_server][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'dtanalysisserver', type = :jar)
  end
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
  only_if { node[:dynatrace][:memory_analysis_server][:installation][:is_required] }
end

dynatrace_run_jar_installer name.to_s do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:memory_analysis_server][:installation][:is_required] }
end

dynatrace_configure_init_scripts name.to_s do
  installer_prefix_dir installer_prefix_dir
  scripts              init_scripts
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  variables(:server_port => server_port, :jvm_xmx => memory_analysis_server_jvm_xmx, :jvm_xms => memory_analysis_server_jvm_xms, :jvm_perm_size => memory_analysis_server_jvm_perm_size, :jvm_max_perm_size => memory_analysis_server_jvm_max_perm_size)
  notifies :restart, "service[#{name}]", :immediately
end

service name.to_s do
  service_name service
  supports     :status => true
  action       [:start, :enable]
end

ruby_block "Waiting for port #{server_port} to become available" do
  block do
    Dynatrace::Helpers.wait_until_port_is_open(server_port)
  end
end
