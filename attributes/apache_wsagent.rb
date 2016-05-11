#
# Cookbook Name:: dynatrace
# Attributes:: apache_wsagent
#
# Copyright 2015, Dynatrace
#

# The path to the Apache HTTP Server's config file.
default['dynatrace']['apache_wsagent']['apache']['config_file_path'] = '/etc/httpd/conf/httpd.conf'

# The path to the Dynatrace Agent library.
default['dynatrace']['apache_wsagent']['linux']['agent_path'] = '/opt/dynatrace/agent/lib64/libdtagent.so'

# The Apache HTTP daemon name.
default['dynatrace']['apache_wsagent']['linux']['apache_daemon'] = 'httpd'

