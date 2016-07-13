#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_file
#
# Copyright 2015, Dynatrace
#

# Let the notifications from nested resources be seen outside this LWRP
use_inline_resources

action :run do
  cookbook_file "Copy file #{new_resource.file_name} to #{new_resource.path}" do
    source new_resource.file_name
    path   new_resource.path
    owner  new_resource.dynatrace_owner
    group  new_resource.dynatrace_group
    mode   new_resource.mode
    action :create
    only_if { !new_resource.file_name.nil? && run_context.has_cookbook_file_in_cookbook?(cookbook_name, new_resource.file_name) }
  end

  if new_resource.file_url != nil
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
      
      if platform_family?('windows')
        # Download from standard URL
        remote_file "Download file from #{new_resource.file_url} to #{new_resource.path}" do
  
          #####################################################################################################################        
          # Note: flag ignore_failure true and atomic_update false are set because following exception is generated on windows:
          # 
          #Chef::Exceptions::Win32APIError
          #-------------------------------
          #No mapping between account names and security IDs was done.
          #---- Begin Win32 API output ----
          #System Error Code: 1332
          #System Error Message: No mapping between account names and security IDs was done.
          #---- End Win32 API output ----
          # 
          # Beside all working properly, remote file is transfered properly.
          # This is workaround and should be removed as soon as the issue will be fixed.
          # So far we haven't slightest idea why it occurs and how it fix. 
          ignore_failure true
          atomic_update false
          #####################################################################################################################        
          
          source new_resource.file_url unless new_resource.file_url.nil?
          path   new_resource.path
          owner  new_resource.dynatrace_owner
          group  new_resource.dynatrace_group
          mode   new_resource.mode
  
          #####################################################################################################################        
          # Note sometimes(!) there is problem on windows with folder rights 0644.
          # I suppose that following code fix this problem first time but later after creating suitable folders should be removed because it generate additional problems - TODO: to investigate
  #        mode   '0777'
  #        rights :read, 'Everyone'
  #        rights :write, 'Everyone'
  #        rights :full_control, 'group_name_or_user_name'
  #        rights :full_control, 'user_name', :applies_to_children => true
          #####################################################################################################################        
   
          use_conditional_get true
  #        action :create
          action :create_if_missing
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
end
