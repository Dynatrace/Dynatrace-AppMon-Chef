#
# Cookbook Name:: dynatrace
# Recipes:: server_pwh_connection
#
# Copyright 2016, Dynatrace
#

rest_user = node['dynatrace']['server']['username']
rest_pass = node['dynatrace']['server']['password']

do_pwh_connection       = node['dynatrace']['server']['do_pwh_connection']
pwh_connection_hostname = node['dynatrace']['server']['pwh_connection']['hostname']
pwh_connection_port     = node['dynatrace']['server']['pwh_connection']['port']
pwh_connection_dbms     = node['dynatrace']['server']['pwh_connection']['dbms']
pwh_connection_database = node['dynatrace']['server']['pwh_connection']['database']
pwh_connection_username = node['dynatrace']['server']['pwh_connection']['username']
pwh_connection_password = node['dynatrace']['server']['pwh_connection']['password']

ruby_block "Waiting for endpoint '/rest/management/pwhconnection/config'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!('https://localhost:8021/rest/management/pwhconnection/config')
  end
  only_if { do_pwh_connection }
end

ruby_block 'Establish the Performance Warehouse connection' do
  block do
    uri = URI('http://localhost:8021/rest/management/pwhconnection/config')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth(rest_user, rest_pass)
    request.body = { :host => pwh_connection_hostname.to_s,
                     :port => pwh_connection_port.to_s,
                     :dbms => pwh_connection_dbms.to_s,
                     :dbname => pwh_connection_database.to_s,
                     :user => pwh_connection_username.to_s,
                     :password => pwh_connection_password.to_s,
                     :usessl => false,
                     :useurl => false,
                     :url => nil }.to_json

    http.request(request)
  end
  only_if { do_pwh_connection }
end
