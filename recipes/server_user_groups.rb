#
# Cookbook Name:: dynatrace
# Recipes:: server_user_groups
#
# NOTE: Works on Dynatrace Server 7.x onwards
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::node_info'

max_boot_time = node['dynatrace']['server']['max_boot_time']
# See docs: https://localhost:8021/api-docs/current/index.html#!/User_Management/getGroups
rest_group_config_url = 'https://localhost:8021/api/v2/usermanagement/groups'

ruby_block "Waiting for endpoint '#{rest_group_config_url}'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!(rest_group_config_url, max_boot_time)
  end
end

# Format of a 'groups' node:
# group1:
#   description: 'some description 1'
#   managementrole: 'Guest'
#   ldapgroup: false
# group2 :
#   description: 'some description 2'
#   managementrole: 'Administrator'
#   ldapgroup: true
#
node['dynatrace']['server']['user_config']['groups'].to_hash.each do |group_id, group_descr|
  ruby_block "Configuring group '#{group_id}'" do
    block do
      rest_user = node['dynatrace']['server']['username']
      rest_pass = node['dynatrace']['server']['password']

      response = Dynatrace::EndpointHelpers.rest_put(URI.escape("#{rest_group_config_url}/#{group_id}"),
                                                     rest_user,
                                                     rest_pass,
                                                     JSON.dump(group_descr),
                                                     :success_codes => %w(201 204 403))

      # Pass over attempts to modify a group (error 403) - it is normal for some predefined groups
      Chef::Log.warn "Could not modify group '#{group_id}': #{response.body}" if response.code == '403'
    end
  end
end
