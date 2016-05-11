#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent
#
# Copyright 2015, Dynatrace
#

apache_daemon = node['dynatrace']['apache_wsagent']['linux']['apache_daemon']

dynatrace_apache_wsagent "Dynatrace Apache WebServer Agent" do
  apache_config_file_path node['dynatrace']['apache_wsagent']['apache']['config_file_path']
  if platform_family?('debian', 'fedora', 'rhel')
    agent_path node['dynatrace']['apache_wsagent']['linux']['agent_path']
  else
    # Unsupported
  end
  action :inject
  notifies :restart, "service[#{apache_daemon}]", :immediately
end

if platform_family?('debian', 'fedora', 'rhel')
  # We only state here that such a daemon already exists. We do this to
  # make the notification mechanism work (see above). 
  service apache_daemon do
    action :nothing
  end
else
  # Unsupported
end
