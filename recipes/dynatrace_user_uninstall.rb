# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Recipes:: dynatrace_user_uninstall
#
# Copyright 2016, Dynatrace
#

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

ruby_block "Stop any running processes of user #{dynatrace_owner}" do
  block do
    Dynatrace::ProcessHelpers.stop_processes(nil, dynatrace_owner, node['platform_family'], 5, 'KILL')
  end
end

if platform_family?('debian', 'fedora', 'rhel')
  # Sometimes processes leave PID files in /tmp...
  execute "find /tmp -maxdepth 1 -user #{dynatrace_owner} | xargs rm -rf"
end

user "Delete user #{dynatrace_owner}" do
  username dynatrace_owner
  action   :remove
end

group "Delete group '#{dynatrace_group}'" do
  group_name dynatrace_group
  action :remove
end
