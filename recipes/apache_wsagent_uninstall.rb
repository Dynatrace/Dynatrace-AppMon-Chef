#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent_uninstall
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::wsagent_package_uninstall'

name = "Dynatrace Apache WebServer Agent uninstall"

apache_config_file_path = node['dynatrace']['apache_wsagent']['apache']['config_file_path']
apache_daemon = node['dynatrace']['apache_wsagent']['linux']['apache_daemon']

if platform_family?('debian', 'fedora', 'rhel')
  if not apache_daemon.empty?
    service apache_daemon do
      action [:stop, :disable]
    end
  end
else
  raise "Unsupported platform"
end

