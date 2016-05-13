#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015, Dynatrace
#

include_recipe "dynatrace::agents_package"

dynatrace_java_agent node['dynatrace']['java_agent']['name'] do
  if platform_family?('debian', 'fedora', 'rhel')
    agent_path node['dynatrace']['java_agent']['linux']['x86_64']['agent_path']
  else
    # Unsupported
  end
end

