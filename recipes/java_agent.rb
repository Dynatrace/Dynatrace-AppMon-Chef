#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015, Dynatrace
#

dynatrace_java_agent node['dynatrace']['java_agent']['name'] do
  env_var_name       node['dynatrace']['java_agent']['env_var']['name']
  env_var_file_name  node['dynatrace']['java_agent']['env_var']['file_name']
  collector_hostname node['dynatrace']['java_agent']['collector']['hostname']
  collector_port     node['dynatrace']['java_agent']['collector']['port']
  if platform_family?('debian', 'fedora', 'rhel')
    agent_path node['dynatrace']['java_agent']['linux']['agent_path']
  else
    # Unsupported
  end
  action :inject
end

