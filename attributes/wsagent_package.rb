#
# Cookbook Name:: dynatrace
# Attributes:: wsagent_package
#
# Copyright 2015, Dynatrace
#

# The name the Dynatrace WebServer Agent as it appears in the Dynatrace Server.
default['dynatrace']['wsagent_package']['agent_name'] = 'dtwsagent'

# The location of the Dynatrace Collector the Web Server Agent shall connect to.
default['dynatrace']['wsagent_package']['collector_hostname'] = 'localhost'

# The port on the Dynatrace Collector the Web Server Agent shall connect to.
default['dynatrace']['wsagent_package']['collector_port'] = '9998'

# The Dynatrace WebServer Agent will be installed into the directory node['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace WebServer Agent installer in the cookbook's files directory.
default['dynatrace']['wsagent_package']['linux']['installer']['file_name'] = 'dynatrace-wsagent.tar'

# A HTTP, HTTPS or FTP URL to the Dynatrace Web Server Agent installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['wsagent_package']['linux']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.2/dynatrace-wsagent-linux-x64.tar'

# The Dynatrace WebServer Agent will be installed into this directory.
default['dynatrace']['wsagent_package']['windows']['installer']['install_dir'] = 'C:\Program Files (x86)\Dynatrace'

# The file name of the Dynatrace WebServer Agent installer in the cookbook's files directory.
default['dynatrace']['wsagent_package']['windows']['installer']['file_name'] = 'dynatrace-agent.msi'

# A HTTP, HTTPS or FTP URL to the Dynatrace WebServer Agent installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['wsagent_package']['windows']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.2/dynatrace-agent.msi'
