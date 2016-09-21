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

# The Apache HTTP daemon name ('httpd' on RedHat and 'apache2' for Ubuntu).
# NOTE: If this recipe is on the same run list as apache2 cookbook (tested v. 3.2.2) it may be needed to clear this
# field (i.e. set value to '') because of a bug in this cookbook. The apache2 recipe defers apache service restart to
# the end of the run list. At the same time we are requiring apache service restart in the apache_wsagent recipe thus
# the service is actually restarted twice during a limited period of time. For some reason the service stop command does
# not wait for the service to be fully stopped and an "Address already in use" error appears.
default['dynatrace']['apache_wsagent']['linux']['apache_daemon'] = 'httpd'

# The path to the Dynatrace Agent libary.
default['dynatrace']['apache_wsagent']['linux']['x86']['agent_path'] = '/opt/dynatrace/agent/lib/libdtagent.so'
default['dynatrace']['apache_wsagent']['linux']['x86_64']['agent_path'] = '/opt/dynatrace/agent/lib64/libdtagent.so'
# This node will be initialized after including the recipe
default['dynatrace']['apache_wsagent']['agent_path'] = nil
