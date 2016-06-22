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
attribute :dynatrace_owner,       :kind_of => String, :default => 'dynatrace'
attribute :dynatrace_group,       :kind_of => String, :default => 'dynatrace'
attribute :s3_bucket,             :kind_of => String, :default => node['dynatrace']['s3']['bucket'] #nil # set to node['dynatrace']['s3']['bucket'] when left nil
attribute :s3_access_key_id,      :kind_of => String, :default => node['dynatrace']['s3']['access_key_id'] #nil # set to node['dynatrace']['s3']['access_key_id'] when left nil
attribute :s3_secret_access_key,  :kind_of => String, :default => node['dynatrace']['s3']['secret_access_key'] #nil # set to node['dynatrace']['s3']['secret_access_key'] when left nil
