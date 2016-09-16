#
# Cookbook Name:: dynatrace
# Recipes:: dynatrace_user
#
# Copyright 2015-2016, Dynatrace
#

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

user "Create system user '#{dynatrace_owner}'" do
  username dynatrace_owner
  system   true
  action   :create
end

group "Create group '#{dynatrace_group}'" do
  group_name dynatrace_group
  members    [dynatrace_owner]
end
