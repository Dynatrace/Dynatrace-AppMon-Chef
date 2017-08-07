#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015-2016, Dynatrace
#

include_recipe 'dynatrace-appmon::agents_package'

unless platform_family?('debian', 'fedora', 'rhel')
  raise 'Unsupported platform family.'
end

agent_name = node['dynatrace']['java_agent']['name']

dynatrace_java_agent agent_name do
  arch = node['dynatrace']['java_agent']['arch']
  agent_path node['dynatrace']['java_agent']['linux'][arch]['agent_path']
end

env_var_name       = node['dynatrace']['java_agent']['env_var']['name']
env_var_file_name  = node['dynatrace']['java_agent']['env_var']['file_name']
owner = node['dynatrace']['owner']
group = node['dynatrace']['group']

template env_var_file_name do
  source  'java_agent/javaopts.sh.erb'
  cookbook 'dynatrace'
  mode    '0755'
  owner   owner
  group   group
  variables(lazy do
    {
      :env_var_name => env_var_name,
      :java_agent_jvm_opts => node['dynatrace']['java_agent']['javaopts'][agent_name.to_s]
    }
  end)
  action :create
  not_if env_var_file_name.nil?
end
