#
# Cookbook Name:: dynatrace
# Resources:: wait_until_rest_endpoint_is_ready
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,     :kind_of => String,  :default => nil
attribute :endpoint, :kind_of => String,  :default => nil
attribute :timeout,  :kind_of => Integer, :default => 120
