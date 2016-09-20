#
# Cookbook Name:: dynatrace
# Recipes:: agents_package_uninstall
#
# Copyright 2016, Dynatrace
# Note: this recipe deletes /opt/dynatrace folder!
#

include_recipe 'dynatrace::prerequisites'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"

  directory "Delete the installer cache directory #{installer_cache_dir}" do
    path   installer_cache_dir
    recursive true
    action :delete
  end

  # NOTE: this may also delete files from other packages!
  link2del = installer_prefix_dir + '/dynatrace'
  dynatrace_delete_directory_by_link "#{link2del}" do
    link2delete link2del
  end
else
  raise "Unsupported platform family."
end

