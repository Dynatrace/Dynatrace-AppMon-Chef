#
# Cookbook Name:: dynatrace
# Providers:: wait_until_rest_endpoint_is_ready
#
# Copyright 2015, Dynatrace
#

action :run do
  ruby_block "Wait for the #{new_resource.name} to become available" do
    block do
      Dynatrace::Helpers::wait_until_rest_endpoint_is_ready!(new_resource.timeout, new_resource.endpoint)
    end
  end
end
