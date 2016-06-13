#
# Mandatory attributes (addresses of nodes)
#
# Cookbook Name:: dynatrace_demo
#
# Copyright 2016, Dynatrace
#
# All rights reserved - Do Not Redistribute
#

#
# Mandatory attributes
#
default['dynatrace']['login_user'] = 'ec2-user'
default['dynatrace']['dynaserver_node_addr'] = nil
default['dynatrace']['collector_node_addr']  = nil
default['dynatrace']['host_agent_name'] = 'hostagent'
default['dynatrace']['easytravel_node_addr'] = nil
default['dynatrace']['server_license_url'] = nil
default['dynatrace']['chef_certificate_name'] = nil
default['dynatrace']['chef_certificate_local_path'] = nil

