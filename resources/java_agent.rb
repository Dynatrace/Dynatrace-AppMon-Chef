#
# Cookbook Name:: dynatrace
# Resource:: java_agent
#
# Author:: Piotr Ozieblo
# Copyright:: Copyright 2016, Dynatrace
#

actions :setjavaopts
default_action :setjavaopts

property :agent_name, String, :name_property => true
property :collector_hostname, String, :default => node['dynatrace']['java_agent']['collector']['hostname']
property :collector_port, String, :default => node['dynatrace']['java_agent']['collector']['port']
property :agent_path, String

action :setjavaopts do
  ruby_block "Creating node JVM options for agent '#{agent_name}'" do
    block do
      node.set['dynatrace']['java_agent']['javaopts'][agent_name] = "-agentpath:#{agent_path}=name=#{agent_name},collector=#{collector_hostname}:#{collector_port}"
    end
  end
end
