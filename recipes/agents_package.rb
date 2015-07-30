#
# Cookbook Name:: dynatrace
# Recipes:: agents_package
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace Agents Package'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['agents_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['agents_package']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
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
    node.set[:dynatrace][:agents_package][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'agent', type=:jar)
  end
end

directory "Create the installation directory #{installer_prefix_dir}" do
  path      installer_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
  recursive true
  action    :create
  only_if { node[:dynatrace][:agents_package][:installation][:is_required] }
end

dynatrace_run_jar_installer "#{name}" do
  installer_path       installer_path
  installer_prefix_dir installer_prefix_dir
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:agents_package][:installation][:is_required] }
end
