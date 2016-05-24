#
# Cookbook Name:: easy_travel
# Attributes:: server
#
# Copyright 2015, easy_travel
#

# 32 or 64
default['easy_travel']['installer']['bitsize'] = '32'

# The Easy Travel will be installed into the directory node['easy_travel']['linux']['installer']['prefix_dir']/easytravel-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['easy_travel']['linux']['installer']['prefix_dir']/easy_travel.
default['easy_travel']['linux']['installer']['prefix_dir'] = '/opt'

# symbolic link name to Easy Travel installation directory
default['easy_travel']['linux']['installer']['link'] = 'easytravel'

# The version
default['easy_travel']['linux']['installer']['version'] = '2.0.0'

# The file name of the easy_travel installer in the cookbook's files directory.
default['easy_travel']['linux']['installer']['file_name'] = 'dynatrace-easytravel-2.0.0.2173-linux-x86.jar'

# A HTTP, HTTPS or FTP URL to the Easy Travel installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['easy_travel']['linux']['installer']['file_url'] = 'https://s3.amazonaws.com/easytravel/dT63/dynatrace-easytravel-2.0.0.2173-linux-x86.jar'

# The file name of the Dynatrace License in the cookbook's files directory.
default['easy_travel']['license']['file_name'] = 'dynatrace-license.key'

# A HTTP, HTTPS or FTP URL to the Dynatrace License in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
default['easy_travel']['license']['file_url'] = nil

# Do not restart the apache server. We will do it manually - in Easy Travel app the server is not started as a normal service.
# Note: when setting an attribute value to nil the overriding mechanism does not work so we use empty value instead.
override['dynatrace']['apache_wsagent']['linux']['apache_daemon'] = ""




