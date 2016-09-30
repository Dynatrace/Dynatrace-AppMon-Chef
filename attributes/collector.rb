#
# Cookbook Name:: dynatrace
# Attributes:: collector
#
# Copyright 2015, Dynatrace
#

# 32 or 64
default['dynatrace']['collector']['installer']['bitsize'] = '64'

# The Dynatrace Collector will be installed into the directory node['dynatrace']['collector']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['dynatrace']['collector']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['collector']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace Collector installer in the cookbook's files directory.
default['dynatrace']['collector']['linux']['installer']['file_name'] = 'dynatrace-collector.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace Collector installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['dynatrace']['collector']['linux']['installer']['file_url'] = 'http://files.dynatrace.com/downloads/OnPrem/dynaTrace/6.5/6.5.0.1289/dynatrace-collector-6.5.0.1289-linux-x86.jar'

# The port where the Dynatrace Collector shall listen for Agents.
default['dynatrace']['collector']['agent']['port'] = '9998'

# The location of the Dynatrace Server the Collector shall connect to.
default['dynatrace']['collector']['server']['hostname'] = 'localhost'

# The port on the Dynatrace Server the Collector shall connect to. Use either 6698 (non-SSL) or 6699 (SSL).
default['dynatrace']['collector']['server']['port'] = '6699'

# The Dynatrace Collector's JVM setting: -Xms
default['dynatrace']['collector']['jvm']['xms'] = nil

# The Dynatrace Collector's JVM setting: -Xmx
default['dynatrace']['collector']['jvm']['xmx'] = nil

# The Dynatrace Collector's JVM setting: -XX:PermSize
default['dynatrace']['collector']['jvm']['perm_size'] = nil

# The Dynatrace Collector's JVM setting: -XX:MaxPermSize
default['dynatrace']['collector']['jvm']['max_perm_size'] = nil
