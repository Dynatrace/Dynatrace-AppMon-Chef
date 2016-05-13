#
# Cookbook Name:: dynatrace
# Attributes:: memory_analysis_server
#
# Copyright 2015, Dynatrace
#

# 32 or 64
default['dynatrace']['memory_analysis_server']['installer']['bitsize'] = '64'

# The Dynatrace Memory Analysis Server will be installed into the directory node['dynatrace']['memory_analysis_server']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['dynatrace']['memory_analysis_server']['linux']['installer']['prefix_dir']/dynatrace.
default['dynatrace']['memory_analysis_server']['linux']['installer']['prefix_dir'] = '/opt'

# The file name of the Dynatrace Memory Analysis Server installer in the cookbook's files directory.
default['dynatrace']['memory_analysis_server']['linux']['installer']['file_name'] = 'dynatrace-analysisserver.jar'

# A HTTP, HTTPS or FTP URL to the Dynatrace Memory Analysis Server installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['dynatrace']['memory_analysis_server']['linux']['installer']['file_url'] = 'http://downloads.dynatracesaas.com/6.3/dynatrace-analysisserver-linux-x86.jar'

# The port where the Dynatrace Memory Analysis Server shall listen for the Dynatrace Server.
default['dynatrace']['memory_analysis_server']['server']['port'] = '7788'

# The Dynatrace Memory Analysis Server's JVM setting: -Xms
default['dynatrace']['memory_analysis_server']['jvm']['xms'] = nil

# The Dynatrace Memory Analysis Server's JVM setting: -Xmx
default['dynatrace']['memory_analysis_server']['jvm']['xmx'] = nil

# The Dynatrace Memory Analysis Server's JVM setting: -XX:PermSize
default['dynatrace']['memory_analysis_server']['jvm']['perm_size'] = nil

# The Dynatrace Memory Analysis Server's JVM setting: -XX:MaxPermSize
default['dynatrace']['memory_analysis_server']['jvm']['max_perm_size'] = nil
