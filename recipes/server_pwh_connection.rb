#
# Cookbook Name:: dynatrace
# Recipes:: server_pwh_connection
#
# Copyright 2016, Dynatrace
#

pwh_connection_hostname = node['dynatrace']['server']['pwh_connection']['hostname']
pwh_connection_port     = node['dynatrace']['server']['pwh_connection']['port']
pwh_connection_dbms     = node['dynatrace']['server']['pwh_connection']['dbms']
pwh_connection_database = node['dynatrace']['server']['pwh_connection']['database']
pwh_connection_username = node['dynatrace']['server']['pwh_connection']['username']
pwh_connection_password = node['dynatrace']['server']['pwh_connection']['password']
success_codes = node['dynatrace']['server']['pwh_connection']['success_codes']

max_boot_time = node['dynatrace']['server']['max_boot_time']

ruby_block "Waiting for endpoint '/rest/management/pwhconnection/config'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!('https://localhost:8021/rest/management/pwhconnection/config', max_boot_time)
  end
end

ruby_block 'Establish the Performance Warehouse connection' do
  # TODO: use a more consistent API to check if server is ready to set PWH connection.
  # Sometimes after restarting the server we got a Net::ReadTimeout error. Checking if REST endpoint is ready (as above)
  # seems to be not enough thus the non-zero retry counter.
  retries 1
  retry_delay 30
  block do
    rest_user = node['dynatrace']['server']['username']
    rest_pass = node['dynatrace']['server']['password']
    body = { :host => pwh_connection_hostname.to_s,
             :port => pwh_connection_port.to_s,
             :dbms => pwh_connection_dbms.to_s,
             :dbname => pwh_connection_database.to_s,
             :user => pwh_connection_username.to_s,
             :password => pwh_connection_password.to_s,
             :usessl => false,
             :useurl => false,
             :url => nil }.to_json

    Dynatrace::EndpointHelpers.rest_put('http://localhost:8021/rest/management/pwhconnection/config',
                                        rest_user,
                                        rest_pass,
                                        body,
                                        :success_codes => success_codes)
  end
end
