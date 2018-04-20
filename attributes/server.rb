# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Attributes:: server
#
# Copyright 2015, Dynatrace
#

# 32 or 64
default['dynatrace']['server']['installer']['bitsize'] = '64'

# The Dynatrace Server will be installed into the directory
# node['dynatrace']['server']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev,
# where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be
# created in node['dynatrace']['server']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['server']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace installer in the cookbook's files directory.
default['dynatrace']['server']['linux']['installer']['file_name'] = 'dynatrace-server.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['dynatrace']['server']['linux']['installer']['file_url'] = 'http://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.0/7.0.0.2469/dynatrace-server-7.0.0.2469-linux-x86.jar'

# The file name of the Dynatrace License in the cookbook's files directory.
default['dynatrace']['server']['license']['file_name'] = nil

# A HTTP, HTTPS or FTP URL to the Dynatrace License in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['dynatrace']['server']['license']['file_url'] = nil

# The port where the Dynatrace Server shall listen for Collectors. Use either 6698 (non-SSL) or 6699 (SSL).
default['dynatrace']['server']['collector_port'] = '6699'

# The sizing of the Dynatrace Server (according to https://community.dynatrace.com/community/display/DOCDT62/Sizing+Settings). Use either 'demo', 'small', 'medium', 'large', 'xlarge', or 'xxlarge'.
default['dynatrace']['server']['sizing'] = 'small'

# The default credentials to communicate with the server (e.g. through REST API)
default['dynatrace']['server']['username'] = 'admin'
default['dynatrace']['server']['password'] = 'admin'

# The PWH connection configuration attribute values are just given as an example.
default['dynatrace']['server']['pwh_connection']['hostname'] = 'localhost'
default['dynatrace']['server']['pwh_connection']['port'] = '5432'

# The DBMS type of the Performance Warehouse. Possible values are 'embedded' (not suitable for production systems), 'db2', 'oracle', 'postgresql', 'sqlazure', 'sqlserver'.
default['dynatrace']['server']['pwh_connection']['dbms'] = 'postgresql'

default['dynatrace']['server']['pwh_connection']['database'] = 'dynatrace-pwh'
default['dynatrace']['server']['pwh_connection']['username'] = 'dynatrace'
default['dynatrace']['server']['pwh_connection']['password'] = 'dynatrace'

# Accepted HTTP return codes when setting PWH connection. Used mainly for integration tests
default['dynatrace']['server']['pwh_connection']['success_codes'] = %w[200]

# Set a longer boot timeout due to the time to open the collector port
# (see log "[SelfMonitoringLauncher] Waiting for self-monitoring Collector startup (max: 90 seconds)")
default['dynatrace']['server']['max_boot_time'] = 300 # in seconds

# LDAP configuration
default['dynatrace']['server']['ldap']['addr'] = nil
default['dynatrace']['server']['ldap']['port'] = nil
default['dynatrace']['server']['ldap']['binddn'] = nil
default['dynatrace']['server']['ldap']['bindpassword'] = nil
default['dynatrace']['server']['ldap']['basedn'] = nil
default['dynatrace']['server']['ldap']['certificatefingerprint'] = nil

# Attributes to configure server groups
default['dynatrace']['server']['user_config']['groups'] = nil
default['dynatrace']['server']['user_config']['saved_groups_file_path'] = nil

# Attributes to configure server users
default['dynatrace']['server']['user_config']['users'] = nil
default['dynatrace']['server']['user_config']['saved_users_file_path'] = nil
