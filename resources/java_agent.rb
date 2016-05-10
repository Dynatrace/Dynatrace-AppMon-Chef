#
# Cookbook Name:: dynatrace
# Resources:: java_agent
#
# Author:: Piotr Ozieblo
# Copyright:: Copyright 2016, Dynatrace
#

actions :inject 
default_action :inject
#TODO :remove action

property :agent_name, String, name_property: true
property :env_var_file_name, String
property :env_var_name, String
property :collector_hostname, String
property :collector_port, String
property :agent_path, String

action :inject do
  # More about magic below here: http://www.fewbytes.com/using-include_recipe-in-chef-lwrp/
  recipe_eval do
    run_context.include_recipe "dynatrace::agents_package"
  end
  ruby_block "Inject Dynatrace Java Agent into #{env_var_file_name}" do
    block do
      Dynatrace::Helpers.file_append_line(env_var_file_name, "export #{env_var_name}=\"$#{env_var_name} -agentpath:#{agent_path}=name=#{agent_name},collector=#{collector_hostname}:#{collector_port}\"")
    end
    not_if { env_var_file_name.nil? }
  end
end

