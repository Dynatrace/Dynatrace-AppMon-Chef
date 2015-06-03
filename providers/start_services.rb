#
# Cookbook Name:: dynatrace
# Providers:: start_services
#
# Copyright 2015, Dynatrace
#

action :run do
  new_resource.services.each do |service_name|
    service "Start and enable the #{new_resource.name}'s service: '#{service_name}'" do
      service_name service_name
      supports     :status => true
      action       [:start, :enable]
    end
  end
end
