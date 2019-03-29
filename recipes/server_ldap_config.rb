# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Recipes:: server_ldap_config
#
# NOTE: Works on Dynatrace 7.x onwards
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
certmd5 = node['dynatrace']['server']['ldap']['certificatefingerprint']

ruby_block 'Configure LDAP' do
  block do
    rest_user = node['dynatrace']['server']['username']
    rest_pass = node['dynatrace']['server']['password']
    body = { :host => ldap_addr.to_s,
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
             :groupdescriptionattribute => 'description',
             :certificatefingerprint => certmd5 }.to_json

    Dynatrace::EndpointHelpers.rest_put(rest_ldap_config_url,
                                        rest_user,
                                        rest_pass,
                                        body,
                                        :success_codes => %w[204])
  end
end
