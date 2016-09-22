#
# Cookbook Name:: dynatrace
# Attributes:: server_update
#
# Copyright 2016, Dynatrace
#

# The file URL of the Dynatrace server update
default['dynatrace']['server']['linux']['update']['update_file'] = 'https://files.dynatrace.com/downloads/fixpacks/dynaTrace-6.3.10.1010.zip'

# A REST URL to update Dynatrace server
default['dynatrace']['server']['linux']['update']['rest_update_url'] = 'https://localhost:8021/rest/management/installjobs'
# A REST URL to check Dynatrace server version after update
default['dynatrace']['server']['linux']['update']['rest_version_url'] = 'https://localhost:8021/rest/management/version'

default['dynatrace']['server']['linux']['update']['user'] = 'admin'
default['dynatrace']['server']['linux']['update']['passwd'] = 'admin'
