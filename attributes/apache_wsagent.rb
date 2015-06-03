#
# Cookbook Name:: dynatrace
# Attributes:: apache_wsagent
#
# Copyright 2015, Dynatrace
#

# The path to the Apache HTTP Server's config file.
default['dynatrace']['apache_wsagent']['apache']['config_file_path'] = '/etc/apache2/apache2.conf'

# The path to the Apache HTTP Server's init.d script.
default['dynatrace']['apache_wsagent']['apache']['init_script_path'] = '/etc/init.d/apache2'

# Whether the init.d script shall be patched so that the Apache HTTP Server service is started only after the Dynatrace Web Server Agent service has started, or not.
default['dynatrace']['apache_wsagent']['apache']['do_patch_init_script'] = false

# The path to the Dynatrace Agent library.
default['dynatrace']['apache_wsagent']['linux']['agent_path'] = '/opt/dynatrace/agent/lib64/libdtagent.so'
