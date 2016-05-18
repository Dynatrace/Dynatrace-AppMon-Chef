#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015, Dynatrace
#

include_recipe "dynatrace::agents_package"

dynatrace_java_agent node['dynatrace']['java_agent']['name'] do
  if platform_family?('debian', 'fedora', 'rhel')
    arch = node['dynatrace']['java_agent']['arch']
    agent_path node['dynatrace']['java_agent']['linux'][arch]['agent_path']
  else
    # Unsupported
  end
end

