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
  supports :manage_home => true
  action   :create
end

# On Windows creating a group with the same name as a just created user throws error: "The account already exists."
unless platform_family?('windows')
  group "Create group '#{dynatrace_group}'" do
    group_name dynatrace_group
    members    [dynatrace_owner]
    action
  end
end
