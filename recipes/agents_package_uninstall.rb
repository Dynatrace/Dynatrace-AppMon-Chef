#
# Cookbook Name:: dynatrace
# Recipes:: agents_package_uninstall
#
# Copyright 2016, Dynatrace
# Note: this receipe deletes /opt/dynatrace folder! 
#

include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::upgrade_system'

name = 'Dynatrace Agents Package uninstall'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['agents_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['agents_package']['linux']['installer']['file_url']

  if installer_prefix_dir == '/opt'
    installer_prefix_dir = installer_prefix_dir + '/dynatrace'
  end
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
  
  # Test if destination directory is empty.'
  dir2delete = installer_prefix_dir
  if Dir.exist?(dir2delete) && !(Dir.entries(dir2delete) - %w{ . .. }).empty? 
    # destination directory already exists and will be deleted
    dynatrace_delete_directory_by_link "#{dir2delete}" do
      link2delete dir2delete
    end
  end
 
elsif platform_family?('windows')
  #TODO
  installer_install_dir = node['dynatrace']['agents_package']['windows']['installer']['install_dir']
  installer_file_name   = node['dynatrace']['agents_package']['windows']['installer']['file_name']
  installer_file_url    = node['dynatrace']['agents_package']['windows']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"
  installer_path      = "#{installer_cache_dir}\\#{installer_file_name}"
else
  raise "Unsupported platform family."
end

directory "Delete the installer cache directory #{installer_cache_dir}" do
  path   installer_cache_dir
  recursive true
  action :delete
  only_if { ::File.directory?(installer_cache_dir)}
end

