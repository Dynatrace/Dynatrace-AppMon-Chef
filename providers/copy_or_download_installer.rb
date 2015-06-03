#
# Cookbook Name:: dynatrace
# Providers:: copy_or_download_installer
#
# Copyright 2015, Dynatrace
#

action :run do
  installer_prefix_dir_exists = ::File.exist?(new_resource.installer_prefix_dir)

  directory "Create the installation directory #{new_resource.installer_prefix_dir}" do
    path  new_resource.installer_prefix_dir
    owner 'dynatrace' unless installer_prefix_dir_exists
    group 'dynatrace' unless installer_prefix_dir_exists
    recursive true
    action :create
  end

  dynatrace_copy_or_download_file "#{new_resource.name}" do
    file_name new_resource.installer_file_name
    file_url  new_resource.installer_file_url
    path      "#{new_resource.installer_prefix_dir}/#{new_resource.installer_file_name}"
  end
end
