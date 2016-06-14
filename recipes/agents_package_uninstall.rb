#
# Cookbook Name:: dynatrace
# Recipes:: agents_package_uninstall
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::helpers'
include_recipe 'dynatrace::upgrade_system'

name = 'Dynatrace Agents Package'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['agents_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['agents_package']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
elsif platform_family?('windows')
  installer_install_dir = node['dynatrace']['agents_package']['windows']['installer']['install_dir']
  installer_file_name   = node['dynatrace']['agents_package']['windows']['installer']['file_name']
  installer_file_url    = node['dynatrace']['agents_package']['windows']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"
  installer_path      = "#{installer_cache_dir}\\#{installer_file_name}"
else
  raise "Unsupported platform family."
end

directory "Delete the installer cache directory" do
  path   installer_cache_dir
  recursive true
  action :delete
end

