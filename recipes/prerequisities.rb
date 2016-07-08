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
  raise "Unsupported platform family."
end

# Needed to by copy_or_download_file LWRP
gem_chef 'aws_sdk' do
  compile_time false
end

