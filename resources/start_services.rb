#
# Cookbook Name:: dynatrace
# Resources:: start_services
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,     :kind_of => String, :default => nil
attribute :services, :kind_of => Array,  :default => []
