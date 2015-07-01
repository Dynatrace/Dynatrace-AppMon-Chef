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
  installer_path       = "#{installer_prefix_dir}/#{installer_file_name}"
else
  # Unsupported
end

dynatrace_copy_or_download_installer "#{name}" do
  installer_prefix_dir installer_prefix_dir
  installer_file_name  installer_file_name
  installer_file_url   installer_file_url
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
end

ruby_block "#{name}" do
  block do
    node.set[:dynatrace][:agents_package][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, 'agent', type=:jar)
  end
end

dynatrace_run_jar_installer "#{name}" do
  installer_prefix_dir installer_prefix_dir
  installer_path       installer_path
  only_if { node[:dynatrace][:agents_package][:installation][:is_required] }
end
