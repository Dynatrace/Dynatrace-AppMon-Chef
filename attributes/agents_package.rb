#
# Cookbook Name:: dynatrace
# Attributes:: agents_package
#
# Copyright 2015, Dynatrace
#

# The Dynatrace Agents package will be installed into the directory node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['agents_package']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace Agents installer in the cookbook's files directory.
default['dynatrace']['agents_package']['linux']['installer']['file_name'] = 'dynatrace-agents.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['agents_package']['linux']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.2/dynatrace-agent-unix.jar'

# The Dynatrace Agents package will be installed into this directory.
default['dynatrace']['agents_package']['windows']['installer']['install_dir'] = 'C:\Program Files (x86)\Dynatrace'

# The file name of the Dynatrace Agents installer in the cookbook's files directory.
default['dynatrace']['agents_package']['windows']['installer']['file_name'] = 'dynatrace-agents.msi'

# A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['agents_package']['windows']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.2/dynatrace-agent.msi'
