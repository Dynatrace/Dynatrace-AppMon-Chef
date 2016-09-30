#
# Cookbook Name:: dynatrace
# Attributes:: server_update
#
# Copyright 2016, Dynatrace
#

# The file URL of the Dynatrace server update
default['dynatrace']['server']['linux']['update']['update_file_url'] = nil

# A REST URL to update Dynatrace server
default['dynatrace']['server']['linux']['update']['rest_update_url'] = 'https://localhost:8021/rest/management/installjobs'
# A REST URL to check Dynatrace server version after update
default['dynatrace']['server']['linux']['update']['rest_version_url'] = 'https://localhost:8021/rest/management/version'

default['dynatrace']['server']['linux']['update']['user'] = 'admin'
default['dynatrace']['server']['linux']['update']['passwd'] = 'admin'

# Max. time to wait for the update to be applied after uploading it to the server (in seconds)
default['dynatrace']['server']['linux']['update']['update_status_timeout'] = 300
# Interval between update status checks (in seconds)
default['dynatrace']['server']['linux']['update']['update_status_retry_sleep'] = 5

# Attributes set internally by the recipe
default['dynatrace']['server']['linux']['update']['isrestartrequired'] = true
default['dynatrace']['server']['linux']['update']['jobid'] = nil
