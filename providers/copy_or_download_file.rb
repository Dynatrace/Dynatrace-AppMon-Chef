#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

action :run do
  include_recipe 's3_file'
  cookbook_file "Copy file #{new_resource.file_name} to #{new_resource.path}" do
    source new_resource.file_name
    path   new_resource.path
    owner  new_resource.dynatrace_owner
    group  new_resource.dynatrace_group
    mode   '0644'
    ignore_failure true
    action :create
    only_if { run_context.has_cookbook_file_in_cookbook?(cookbook_name, new_resource.file_name) }
  end

  if new_resource.remote_path != nil
    # Download from normal URL
    if new_resource.s3_bucket.nil?
      remote_file "Download file from #{new_resource.remote_path} to #{new_resource.path}" do
        source new_resource.remote_path unless new_resource.remote_path.nil?
        path   new_resource.path
        owner  new_resource.dynatrace_owner
        group  new_resource.dynatrace_group
        mode   '0644'
        use_conditional_get true
        action :create
      end
    else
      # Download from S3
      s3_file "Download from Amazon S3 (#{new_resource.s3_bucket}/#{new_resource.remote_path}) to #{new_resource.path}" do
        remote_path           new_resource.remote_path
        path                  new_resource.path
        bucket                new_resource.s3_bucket
        aws_access_key_id     new_resource.s3_access_key_id
        aws_secret_access_key new_resource.s3_secret_access_key
        owner                 new_resource.dynatrace_owner
        group                 new_resource.dynatrace_group
        mode                  '0644'
        action                :create
      end
    end
  end
end
