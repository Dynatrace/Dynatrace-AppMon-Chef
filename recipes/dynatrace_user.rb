#
# Cookbook Name:: dynatrace
# Recipes:: dynatrace_user
#
# Copyright 2015, Dynatrace
#

user "Create system user 'dynatrace'" do
  username 'dynatrace'
  comment  'Dynatrace user'
  system   true
  action   :create
end

group "Create group 'dynatrace'" do
  group_name 'dynatrace'
  members    ['dynatrace']
end
