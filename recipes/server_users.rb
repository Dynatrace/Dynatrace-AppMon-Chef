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

users_file_path = node['dynatrace']['server']['user_config']['saved_users_file_path']

ruby_block "Load users from file '#{users_file_path}'" do
  block do
    node.set['dynatrace']['server']['user_config']['users'] = JSON.parse(File.read(users_file_path))
  end
  only_if { ::File.exist?(users_file_path) }
end

# Format of a 'users' node:
# newuserid:
#   fullname: 'New User'
#   email: new@user.com
#   password: SecretPassword
ruby_block 'Configuring users' do
  block do
    rest_user = node['dynatrace']['server']['username']
    rest_pass = node['dynatrace']['server']['password']

    node['dynatrace']['server']['user_config']['users'].to_hash.each do |user_id, user_descr|
      Chef::Log.info "Configuring user #{user_id}"
      Dynatrace::EndpointHelpers.rest_put(URI.escape("#{rest_user_config_url}/#{user_id}"),
                                          rest_user,
                                          rest_pass,
                                          JSON.dump(user_descr),
                                          :success_codes => %w(201 204))
    end
  end
end
