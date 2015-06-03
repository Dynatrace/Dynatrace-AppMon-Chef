#
# Cookbook Name:: dynatrace
# Resources:: wait_until_port_is_open
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,    :kind_of => String,  :default => nil
attribute :port,    :kind_of => String,  :default => nil
attribute :ip,      :kind_of => String,  :default => '127.0.0.1'
attribute :timeout, :kind_of => Integer, :default => 120
