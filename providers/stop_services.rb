#
# Cookbook Name:: dynatrace
# Providers:: stop_services
#
# Copyright 2015, Dynatrace
#

action :run do
  new_resource.services.each do |service_name|
    service "Stop and disable the #{new_resource.name}'s service: '#{service_name}'" do
      service_name service_name
      supports     :status => true
      action       [:stop, :disable]
      ignore_failure true
    end
  end
end
