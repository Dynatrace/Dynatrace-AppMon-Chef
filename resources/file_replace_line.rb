#
# Cookbook Name:: dynatrace
# Resources:: file_replace_line
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :path,    :kind_of => String, :default => nil
attribute :regex,   :kind_of => Regexp, :default => nil
attribute :replace, :kind_of => String, :default => nil
