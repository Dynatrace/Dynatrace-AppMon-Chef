#
# Cookbook Name:: dynatrace
# Attributes:: host_agent
#
# Copyright 2016, Dynatrace
#

# The name of the host agent (used for agent mapping on the dynaTrace Server). Default: Name host
default['dynatrace']['host_agent']['host_agent_name'] = 'host'

# The address of the dynaTrace Collector this agent should connect to. The address is of the form host:port, e.g. exampleserver:9998. Default: Server localhost
default['dynatrace']['host_agent']['collector'] = 'localhost'

# 32 or 64
default['host_agent']['installer']['bitsize'] = '64'

# The Dynatrace Host Agent package will be installed into the directory node['dynatrace']['host_agent']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. 
# A symbolic link to the actual installation directory will be created in node['dynatrace']['host_agent']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['host_agent']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace Host Agent installer in the cookbook's files directory.
default['dynatrace']['host_agent']['installer']['file_name'] = 'dynatrace-hostagent-'

# A HTTP, HTTPS or FTP URL to the Dynatrace Host Agent installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['host_agent']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.3/'
