#
# Cookbook Name:: dynatrace
# Providers:: wait_until_port_is_open
#
# Copyright 2015, Dynatrace
#

action :run do
  ruby_block "Wait for the #{new_resource.name} to become available" do
    block do
      Dynatrace::Helpers::wait_until_port_is_open(new_resource.timeout, new_resource.ip, new_resource.port)
    end
  end
end
