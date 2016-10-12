#
# Cookbook Name:: dynatrace
# Recipes:: prerequisites
#
# Copyright 2016, Dynatrace
#

if platform_family?('debian', 'fedora', 'rhel')
  # Ensure the package is installed before using run_jar_installer and run_tar_installer LWRPs
  package 'rsync' do
    action :install
  end
end

# needed by dynatrace_copy_or_download_file to download from S3
chef_gem 'aws-sdk' do
  compile_time false
end
