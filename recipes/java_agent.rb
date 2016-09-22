#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015-2016, Dynatrace
#

include_recipe 'dynatrace::agents_package'

dynatrace_java_agent node['dynatrace']['java_agent']['name'] do
  arch = node['dynatrace']['java_agent']['arch']
  agent_path node['dynatrace']['java_agent']['linux'][arch]['agent_path']
end
