#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

# Let the notifications from nested resources be seen outside this LWRP
use_inline_resources

action :run do
  if !new_resource.file_name.nil? && run_context.has_cookbook_file_in_cookbook?(cookbook_name, new_resource.file_name) && !new_resource.file_url.nil?
    raise "There are file name(#{new_resource.file_name}) and file url(#{new_resource.file_url}) specified. Specify one of them to use locally provided file or to download file using url."
  end
  cookbook_file "Copy file #{new_resource.file_name} to #{new_resource.path}" do
    source new_resource.file_name
    path   new_resource.path
    owner  new_resource.dynatrace_owner
    group  new_resource.dynatrace_group
    mode   new_resource.mode
    action :create
    only_if { !new_resource.file_name.nil? && run_context.has_cookbook_file_in_cookbook?(cookbook_name, new_resource.file_name) }
  end

  unless new_resource.file_url.nil?
    if new_resource.file_url.start_with?('s3://')
      # Download from S3
      # Example of S3 URL: s3://bucket_name/path/to/filename
      dynatrace_s3_file "Download from Amazon S3 (#{new_resource.file_url}) to #{new_resource.path}" do
        source                new_resource.file_url
        target                new_resource.path
        region                new_resource.s3_region
        access_key_id         new_resource.s3_access_key_id
        secret_access_key     new_resource.s3_secret_access_key
        owner                 new_resource.dynatrace_owner
        group                 new_resource.dynatrace_group
        mode                  new_resource.mode
        action                :create
      end
    else
      # Download from standard URL
      remote_file "Download file from #{new_resource.file_url} to #{new_resource.path}" do
        source new_resource.file_url unless new_resource.file_url.nil?
        path   new_resource.path
        owner  new_resource.dynatrace_owner
        group  new_resource.dynatrace_group
        mode   new_resource.mode
        use_conditional_get true
        action :create
      end
    end
  end
end
