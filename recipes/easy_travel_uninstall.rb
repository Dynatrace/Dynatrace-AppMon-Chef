#
# Cookbook Name:: easy_travel_uninstall
# Recipes:: dynatrace
# will uninstall Easy Travel
# NOTE: Be careful - you will lost your Easy Travel configuration!!!
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'

name = 'Easy Travel'
include_recipe 'dynatrace::node_info'
include_recipe 'dynatrace::agents_package_uninstall'
include_recipe 'dynatrace::apache_wsagent_uninstall'

if platform_family?('debian', 'fedora', 'rhel')

  ruby_block "Stop any running instance of #{name}" do
    block do
      puts 'Stoping processes'
      Dynatrace::Helpers.stop_processes(node['easy_travel']['proc_pattern'], node['platform_family'], 30)
      Dynatrace::Helpers.stop_processes('/opt/easytravel.*/httpd', node['platform_family'], 30)
      Dynatrace::Helpers.stop_processes('/opt/EasyTravel/.*/httpd', node['platform_family'], 30)
      Dynatrace::Helpers.stop_processes('dtwsagent', node['platform_family'], 30)
    end
  end

  easytravel_owner = node['easy_travel']['owner']
  easytravel_group = node['easy_travel']['group']
  installer_prefix_dir = node['easy_travel']['linux']['installer']['prefix_dir']
  installer_file_name  = node['easy_travel']['linux']['installer']['file_name']
  installer_link  = node['easy_travel']['linux']['installer']['link']
  dir2delete = installer_prefix_dir + '/' + installer_link

  # Test if destination directory is empty.'
  if Dir.exist?(dir2delete) && !(Dir.entries(dir2delete) - %w{ . .. }).empty? 
    # destination directory already exists and will be deleted
    puts 'Destination directory:' + dir2delete + ' exists and is NOT empty. Easy Travel will be uninstalled. You will lost your configuration.'

    dynatrace_delete_directory_by_link "#{dir2delete}" do
      link2delete dir2delete
    end
    
#    user "Delete user '#{easytravel_owner}'" do
#      username easytravel_owner
#      supports :manage_home=>true
#      action   :remove
#    end
#
#    group "Delete group '#{easytravel_group}'" do
#      group_name easytravel_group
#      action     :remove
#    end
    
  else
    log 'Destination directory:' + dir2delete + ' not exists. It looks loke Easy Travel is not installed.'
  end
  
else
  # Unsupported platform
  log 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be uninstalled.'
end
