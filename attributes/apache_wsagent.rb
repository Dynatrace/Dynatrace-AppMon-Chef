#
# Cookbook Name:: dynatrace
# Attributes:: apache_wsagent
#
# Copyright 2016, Dynatrace
#

# x86 or x86_64
default['dynatrace']['apache_wsagent']['arch'] = 'x86_64'

# The path to the Apache HTTP Server's config file.
default['dynatrace']['apache_wsagent']['apache']['config_file_path'] = '/etc/httpd/conf/httpd.conf'

# The Apache HTTP daemon name.
default['dynatrace']['apache_wsagent']['linux']['apache_daemon'] = 'httpd'

# The path to the Dynatrace Agent libary.
default['dynatrace']['apache_wsagent']['linux']['x86']['agent_path'] = '/opt/dynatrace/agent/lib/libdtagent.so'
default['dynatrace']['apache_wsagent']['linux']['x86_64']['agent_path'] = '/opt/dynatrace/agent/lib64/libdtagent.so'
# This node will be initialized after including the recipe
default['dynatrace']['apache_wsagent']['agent_path'] = nil
