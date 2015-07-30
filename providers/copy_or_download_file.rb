#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

action :run do
  remote_file "Download file from #{new_resource.file_url} to #{new_resource.path}" do
    source new_resource.file_url unless new_resource.file_url.nil?
    path   new_resource.path
    owner  new_resource.dynatrace_owner
    group  new_resource.dynatrace_group
    mode   '0644'
    action :create_if_missing
    only_if { !::File.exist?(new_resource.path) }
  end

  cookbook_file "Copy file #{new_resource.file_name} to #{new_resource.path}" do
    source new_resource.file_name
    path   new_resource.path
    owner  new_resource.dynatrace_owner
    group  new_resource.dynatrace_group
    mode   '0644'
    ignore_failure true
    action :create_if_missing
    only_if { !::File.exist?(new_resource.path) }
  end
end
