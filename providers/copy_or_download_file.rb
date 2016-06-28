#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

# Let the notifications from nested resources be seen outside this LWRP
use_inline_resources

action :run do
  include_recipe 's3_file' if !defined? s3_file
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

  if new_resource.file_url != nil
    if new_resource.file_url.start_with?('s3://')
      # Download from S3
      # Example of S3 URL: s3://bucket_name/path/to/filename
      s3_url = new_resource.file_url.dup
      s3_url.slice!('s3://')
      s3_path_elems = s3_url.split('/', 2)

      s3_file "Download from Amazon S3 (#{new_resource.file_url}) to #{new_resource.path}" do
        remote_path           s3_path_elems[1]
        path                  new_resource.path
        bucket                s3_path_elems[0]
        aws_access_key_id     new_resource.s3_access_key_id
        aws_secret_access_key new_resource.s3_secret_access_key
        owner                 new_resource.dynatrace_owner
        group                 new_resource.dynatrace_group
        mode                  '0644'
        action                :create
      end
      # NOTE: when uploading the file to S3 using multi-part upload the ETag will not match the one calculated locally
      # thus the file will always be downloaded. Read https://github.com/adamsb6/s3_file#md5-and-multi-part-upload for
      # details.
    else
      # Download from standard URL
      remote_file "Download file from #{new_resource.file_url} to #{new_resource.path}" do
        source new_resource.file_url unless new_resource.file_url.nil?
        path   new_resource.path
        owner  new_resource.dynatrace_owner
        group  new_resource.dynatrace_group
        mode   '0644'
        use_conditional_get true
        action :create
      end
    end
  end
end
