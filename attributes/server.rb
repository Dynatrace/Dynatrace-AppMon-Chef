#
# Cookbook Name:: dynatrace
# Attributes:: server
#
# Copyright 2015, Dynatrace
#

# The Dynatrace Server will be installed into the directory node['dynatrace']['server']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['dynatrace']['server']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['server']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace installer in the cookbook's files directory.
default['dynatrace']['server']['linux']['installer']['file_name'] = 'dynatrace.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['server']['linux']['installer']['file_url'] = nil

# The file name of the Dynatrace License in the cookbook's files directory.
default['dynatrace']['server']['license']['file_name'] = 'dynatrace-license.key'

# A HTTP, HTTPS or FTP URL to the Dynatrace License in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['server']['license']['file_url'] = 'http://downloads.dynatracesaas.com/6.2/dynatrace-linux-x64.jar'

# The port where the Dynatrace Server shall listen for Collectors. Use either 6698 (non-SSL) or 6699 (SSL).
default['dynatrace']['server']['collector_port'] = '6698'

# The sizing of the Dynatrace Server (according to https://community.dynatrace.com/community/display/DOCDT62/Sizing+Settings). Use either 'demo', 'small', 'medium', 'large', 'xlarge', or 'xxlarge'.
default['dynatrace']['server']['sizing'] = nil

# Whether a connection to an existing Performance Warehouse (database) shall be established, or not. Requires Dynatrace >= v6.2.
default['dynatrace']['server']['do_pwh_connection'] = false

default['dynatrace']['server']['pwh_connection']['hostname'] = 'localhost'
default['dynatrace']['server']['pwh_connection']['port'] = '5432'

# The DBMS type of the Performance Warehouse. Possible values are 'embedded' (not suitable for production systems), 'db2', 'oracle', 'postgresql', 'sqlazure', 'sqlserver'.
default['dynatrace']['server']['pwh_connection']['dbms'] = 'postgresql'

default['dynatrace']['server']['pwh_connection']['database'] = 'dynatrace-pwh'
default['dynatrace']['server']['pwh_connection']['username'] = 'dynatrace'
default['dynatrace']['server']['pwh_connection']['password'] = 'dynatrace'
