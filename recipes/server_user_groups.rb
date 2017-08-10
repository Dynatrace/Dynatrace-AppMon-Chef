#
# Cookbook Name:: dynatrace
# Recipes:: server_user_groups
#
# NOTE: Works on Dynatrace Server 7.x onwards
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace-appmon::node_info'

max_boot_time = node['dynatrace']['server']['max_boot_time']
# See docs: https://localhost:8021/api-docs/current/index.html#!/User_Management/getGroups
rest_group_config_url = 'https://localhost:8021/api/v2/usermanagement/groups'

ruby_block "Waiting for endpoint '#{rest_group_config_url}'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!(rest_group_config_url, max_boot_time)
  end
end

groups_file_path = node['dynatrace']['server']['user_config']['saved_groups_file_path']

ruby_block "Load groups from file '#{groups_file_path}'" do
  block do
    node.normal['dynatrace']['server']['user_config']['groups'] = JSON.parse(File.read(groups_file_path))
  end
  only_if { ::File.exist?(groups_file_path.to_s) }
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

ruby_block 'Configuring groups' do
  block do
    rest_user = node['dynatrace']['server']['username']
    rest_pass = node['dynatrace']['server']['password']
    node['dynatrace']['server']['user_config']['groups'].to_hash.each do |group_id, group_descr|
      Chef::Log.info "Configuring group '#{group_id}'"
      response = Dynatrace::EndpointHelpers.rest_put(URI.escape("#{rest_group_config_url}/#{group_id}"),
                                                     rest_user,
                                                     rest_pass,
                                                     JSON.dump(group_descr),
                                                     :success_codes => %w(201 204 403))

      # Pass over erroneous attempts to modify a group (error 403) - it is normal for some predefined groups
      # e.g. 'Personal System Profile Access' group
      Chef::Log.warn "Could not modify group '#{group_id}': #{response.body}" if response.code == '403'
    end
  end
  only_if { node['dynatrace']['server']['user_config']['groups'] }
end

log 'No user groups configuration provided' do
  level :warn
  not_if { node['dynatrace']['server']['user_config']['groups'] }
end
