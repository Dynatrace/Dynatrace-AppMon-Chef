#
# Cookbook Name:: dynatrace
# Recipes:: agents_package
#
# Copyright 2017, Dynatrace
#

include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::dynatrace_user'

name = 'Dynatrace One Agent'

raise 'Unsupported platform family.' unless platform_family?('debian', 'fedora', 'rhel')

package_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
directory 'Create the package cache directory' do
  path   package_cache_dir
  action :create
end

package_file_url = node['dynatrace']['one_agent']['linux']['package']['file_url']
package_prefix_dir = node['dynatrace']['one_agent']['linux']['package']['prefix_dir']
package_file_name = node['dynatrace']['one_agent']['linux']['package']['file_name']
package_file_path = "#{package_cache_dir}/#{package_file_name}"

ruby_block "Check if #{name} already installed" do
  block do
    node.set[:dynatrace][:one_agent][:installation][:is_required] = Dynatrace::PackageHelpers.requires_installation?(package_prefix_dir, package_file_path, 'agent/bin/linux-x86-32/liboneagentloader.so', type = :tar)
  end
end

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']
fresh_installer_action = "#{name} installer changed"

dynatrace_copy_or_download_file "Downloading One Agent package: #{package_file_url}" do
  file_name       package_file_name
  file_url        package_file_url
  path            package_file_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
  notifies :run, "ruby_block[#{fresh_installer_action}]", :immediately
end

ruby_block fresh_installer_action.to_s do
  block do
    raise "The downloaded installer package would overwrite existing installation of the #{name}."
  end
  action :nothing
  not_if { node[:dynatrace][:one_agent][:installation][:is_required] }
end

directory "Create the installation directory #{package_prefix_dir}" do
  path      package_prefix_dir
  owner     dynatrace_owner unless ::File.exist?(package_prefix_dir)
  group     dynatrace_group unless ::File.exist?(package_prefix_dir)
  recursive true
  action    :create
end

symlink_name = node['dynatrace']['one_agent']['linux']['package']['symlink_name']

dynatrace_run_tar_installer name.to_s do
  installer_path       package_file_path
  installer_prefix_dir package_prefix_dir
  symlink_name         symlink_name
  dynatrace_owner      dynatrace_owner
  dynatrace_group      dynatrace_group
  only_if { node[:dynatrace][:one_agent][:installation][:is_required] }
end
