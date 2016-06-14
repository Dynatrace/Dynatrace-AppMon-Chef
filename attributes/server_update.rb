#
# Cookbook Name:: dynatrace
# Attributes:: server_update
#
# Copyright 2016, Dynatrace
#

# The file name of the Dynatrace server update in the user home directory.
default['dynatrace']['server']['linux']['update']['update_file'] = '/home/ec2-user/dynaTrace-6.3.4.1034.dtf'

# A REST URL to update Dynatrace server
default['dynatrace']['server']['linux']['update']['rest_update_url'] = 'https://localhost:8021/rest/management/installjobs/'

default['dynatrace']['server']['linux']['update']['user'] = 'admin'
default['dynatrace']['server']['linux']['update']['passwd'] = 'admin'
