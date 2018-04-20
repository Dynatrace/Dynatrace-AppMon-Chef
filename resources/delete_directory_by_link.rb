# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Resources:: delete_directory_by_link
# Copyright 2016, Dynatrace
#

actions :run
default_action :run

attribute :link2delete, :kind_of => String, :default => 'dynatrace'
