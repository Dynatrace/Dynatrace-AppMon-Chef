#
# Cookbook Name:: dynatrace
# Providers:: configure_init_scripts
#
# Copyright 2015, Dynatrace
#

use_inline_resources

action :run do
  if platform_family?('debian')
    linux_service_start_runlevels = '2 3 4 5'
    linux_service_stop_runlevels = '0 1 6'
  else
    linux_service_start_runlevels = '3 5'
    linux_service_stop_runlevels = '0 1 2 6'
  end

  new_resource.scripts.each do |script|
    template "Configure and copy the #{new_resource.name}'s '#{script}' init script" do
      source "init.d/#{script}.erb"
      path   "#{new_resource.installer_prefix_dir}/dynatrace/init.d/#{script}"
      owner  new_resource.dynatrace_owner
      group  new_resource.dynatrace_group
      mode   '0755'
      variables({
        :linux_service_start_runlevels => linux_service_start_runlevels,
        :linux_service_stop_runlevels => linux_service_stop_runlevels,
        :installer_prefix_dir => new_resource.installer_prefix_dir,
        :user => new_resource.dynatrace_owner
      }.merge(new_resource.variables))
      action :create
    end

    link "Make the '#{script}' init script available in /etc/init.d" do
      to          "#{new_resource.installer_prefix_dir}/dynatrace/init.d/#{script}"
      target_file "/etc/init.d/#{script}"
      action :create
    end
  end
end
