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

user "Delete user '#{dynatrace_owner}'" do
  username dynatrace_owner
  action   :remove
end

group "Delete group '#{dynatrace_group}'" do
  group_name dynatrace_group
  action :remove
end
