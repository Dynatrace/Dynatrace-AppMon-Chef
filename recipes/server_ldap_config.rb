#
# Cookbook Name:: dynatrace
# Recipes:: server_ldap_config
#
# Copyright 2016, Dynatrace
#

max_boot_time = node['dynatrace']['server']['max_boot_time']
# See docs: https://localhost:8021/api-docs/current/index.html#!/User_Management/getLdapConfig
rest_ldap_config_url = 'https://localhost:8021/api/v2/usermanagement/ldap'

ruby_block "Waiting for endpoint '#{rest_ldap_config_url}'" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!(rest_ldap_config_url, max_boot_time)
  end
end

ldap_addr = node['dynatrace']['server']['ldap']['addr']
ldap_port = node['dynatrace']['server']['ldap']['port']
binddn = node['dynatrace']['server']['ldap']['binddn']
bindpassword = node['dynatrace']['server']['ldap']['bindpassword']
basedn = node['dynatrace']['server']['ldap']['basedn']

ruby_block 'Configure LDAP' do
  block do
    uri = URI(rest_ldap_config_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Put.new(uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    rest_user = node['dynatrace']['server']['username']
    rest_pass = node['dynatrace']['server']['password']
    request.basic_auth(rest_user, rest_pass)
    request.body = { :host => ldap_addr.to_s,
                     :port => ldap_port.to_i,
                     :usessl => true,
                     :binddn => binddn.to_s,
                     :bindpassword => bindpassword.to_s,
                     :basedn => basedn.to_s,
                     :useraccountattribute => 'sAMAccountName',
                     :usernameattribute => 'name',
                     :useremailattribute => 'mail',
                     :memberattribute => 'memberOf',
                     :groupobjectclass => 'group',
                     :groupdescriptionattribute => 'description' }.to_json

    http.request(request)
  end
end
