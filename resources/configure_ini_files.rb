# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Resources:: configure_ini_files
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :name,                 :kind_of => String, :default => nil
attribute :installer_prefix_dir, :kind_of => String, :default => nil
attribute :ini_files,            :kind_of => Array,  :default => []
attribute :variables,            :kind_of => Hash,   :default => {}
attribute :dynatrace_owner,      :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,      :kind_of => String, :default => 'dynatrace'
