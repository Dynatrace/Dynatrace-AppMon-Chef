#
# Cookbook Name:: dynatrace
# Recipes:: java_agent
#
# Copyright 2015, Dynatrace
#

include_recipe 'dynatrace::agents_package'

env_var_name       = node['dynatrace']['java_agent']['env_var']['name']
env_var_file_name  = node['dynatrace']['java_agent']['env_var']['file_name']
agent_name         = node['dynatrace']['java_agent']['name']
collector_hostname = node['dynatrace']['java_agent']['collector']['hostname']
collector_port     = node['dynatrace']['java_agent']['collector']['port']

if platform_family?('debian', 'fedora', 'rhel')
  agent_path = node['dynatrace']['java_agent']['linux']['agent_path']
end

ruby_block "Inject Dynatrace Java Agent into #{env_var_file_name}" do
  block do
    Dynatrace::Helpers.file_append_line(env_var_file_name, "export #{env_var_name}=\"$#{env_var_name} -agentpath:#{agent_path}=name=#{agent_name},collector=#{collector_hostname}:#{collector_port}\"")
  end
  not_if env_var_file_name.nil?
end
