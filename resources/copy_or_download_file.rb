# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Resources:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

actions :run
default_action :run

attribute :file_name,             :kind_of => String, :default => nil
attribute :file_url,              :kind_of => String, :default => nil
attribute :path,                  :kind_of => String, :default => nil
attribute :mode,                  :kind_of => String, :default => '0644'
attribute :dynatrace_owner,       :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,       :kind_of => String, :default => 'dynatrace'
attribute :s3_region,             :kind_of => String, :default => node['dynatrace']['s3']['region']
attribute :s3_access_key_id,      :kind_of => String, :default => node['dynatrace']['s3']['access_key_id']
attribute :s3_secret_access_key,  :kind_of => String, :default => node['dynatrace']['s3']['secret_access_key']
