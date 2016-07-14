#
# Cookbook Name:: dynatrace
# Recipes:: helpers
#
# Copyright 2016, Dynatrace
#

if platform_family?('debian', 'fedora', 'rhel')
  # Ensure the package is installed before using run_jar_installer and run_tar_installer LWRPs
  package 'rsync' do
    action :install
  end
else
  log "Unsupported platform family." do
    level :warn
  end
end

if !platform_family?('windows')      
                    # on Windows we have NoMemoryError failed to allocate memory, 
                    # The issue got resolved by applying the windows hot fix KB2842230 on aws ami.
                    #  [https://support.microsoft.com/en-us/kb/2842230]
  # Needed to by copy_or_download_file LWRP; 
  chef_gem 'aws-sdk' do
    compile_time false
  end
end

