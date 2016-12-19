#
# Cookbook Name:: dynatrace
# Recipes:: server_users
#
# NOTE: Works on Dynatrace Server 7.x onwards
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::node_info'

max_boot_time = node['dynatrace']['server']['max_boot_time']
# See docs: https://localhost:8021/api-docs/current/index.html#!/User_Management/getUser
rest_user_config_url = 'https://localhost:8021/api/v2/usermanagement/users'

ruby_block "Waiting for endpoint '#{rest_user_config_url}'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!(rest_user_config_url, max_boot_time)
  end
end

# Format of a 'users' node:
# newuserid:
#   fullname: 'New User'
#   email: new@user.com
#   password: SecretPassword
node['dynatrace']['server']['user_config']['users'].to_hash.each do |user_id, user_descr|
  ruby_block "Configuring user '#{user_id}'" do
    block do
      rest_user = node['dynatrace']['server']['username']
      rest_pass = node['dynatrace']['server']['password']

      Dynatrace::EndpointHelpers.rest_put(URI.escape("#{rest_user_config_url}/#{user_id}"),
                                          rest_user,
                                          rest_pass,
                                          JSON.dump(user_descr),
                                          :success_codes => %w(201 204))
    end
  end
end
