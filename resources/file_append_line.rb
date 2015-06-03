#
# Cookbook Name:: dynatrace
# Resources:: file_append_line
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :path, :kind_of => String, :default => nil
attribute :line, :kind_of => String, :default => nil
