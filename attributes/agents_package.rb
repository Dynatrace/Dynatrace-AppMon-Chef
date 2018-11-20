#
# Cookbook Name:: dynatrace
# Attributes:: agents_package
#
# Copyright 2015, Dynatrace
#

# The Dynatrace Agents package will be installed into the directory
# node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev,
# where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will
# be created in node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['agents_package']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace Agents installer in the cookbook's files directory.
default['dynatrace']['agents_package']['linux']['installer']['file_name'] = 'dynatrace-agent.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['dynatrace']['agents_package']['linux']['installer']['file_url'] = 'http://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-agent-7.2.0.1697-unix.jar'

# The Dynatrace Agents package will be installed into this directory.
default['dynatrace']['agents_package']['windows']['installer']['install_dir'] = 'C:\Program Files (x86)\Dynatrace'

# The file name of the Dynatrace Agents installer in the cookbook's files directory.
default['dynatrace']['agents_package']['windows']['installer']['file_name'] = 'dynatrace-agent.msi'

# A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['dynatrace']['agents_package']['windows']['installer']['file_url'] = 'http://files.dynatrace.com/downloads/OnPrem/dynaTrace/7.2/7.2.0.1697/dynatrace-agent-7.2.0.1697-x86.msi'
