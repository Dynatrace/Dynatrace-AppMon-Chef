#
# Cookbook Name:: easy_travel
# Attributes:: server
#
# Copyright 2015, easy_travel
#

# x86 or x86_64
default['easy_travel']['installer']['arch'] = 'x86'

# The Easy Travel will be installed into the directory node['easy_travel']['linux']['installer']['prefix_dir']/easytravel-$major-$minor-$rev, where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will be created in node['easy_travel']['linux']['installer']['prefix_dir']/easy_travel.
default['easy_travel']['linux']['installer']['prefix_dir'] = '/opt'
default['easy_travel']['windows']['installer']['prefix_dir'] = 'EasyTravel'

# symbolic link name to Easy Travel installation directory
default['easy_travel']['linux']['installer']['link'] = 'easytravel'

# The version
default['easy_travel']['installer']['version'] = '2.0.0'

# The file name of the easy_travel installer in the cookbook's files directory.
default['easy_travel']['linux']['installer']['file_name'] = 'dynatrace-easytravel-2.0.0.2173-linux-x86.jar'
default['easy_travel']['windows']['installer']['file_name'] = 'dynatrace-easytravel-windows-x86_64-2.0.0.2347.msi'

# A HTTP, HTTPS or FTP URL to the Easy Travel installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['easy_travel']['linux']['installer']['file_url'] = 'https://s3.amazonaws.com/easytravel/dT63/dynatrace-easytravel-2.0.0.2173-linux-x86.jar'
#default['easy_travel']['linux']['installer']['file_url'] = 'https://s3.amazonaws.com/downloads.dynasprint/easytravel/2.0.0.2347/dynatrace-easytravel-windows-x86_64-2.0.0.2347.msi'
default['easy_travel']['windows']['installer']['file_url'] = 'https://s3.amazonaws.com/dynatrace-automation/dynatrace-easytravel-windows-x86_64-2.0.0.2347.msi'


# The file name of the Dynatrace License in the cookbook's files directory.
default['easy_travel']['license']['file_name'] = 'dynatrace-license.key'

# A HTTP, HTTPS or FTP URL to the Dynatrace License in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
default['easy_travel']['license']['file_url'] = nil

# The process pattern to search when the app needs to be stopped
default['easy_travel']['proc_pattern'] = 'java.*com.dynatrace.easytravel.weblauncher.jar'

# User owning the app. It will be created if it does not exist yet.
default['easy_travel']['owner'] = 'easytravel'
default['easy_travel']['group'] = 'easytravel'
  
# Do not restart the apache server. We will do it manually - in Easy Travel app the server is not started as a normal service.
# Note: when setting an attribute value to nil the overriding mechanism does not work so we use empty value instead.
override['dynatrace']['apache_wsagent']['linux']['apache_daemon'] = ""

# The default group and scenario to start after launching the app e.g. 'Standard' scenario in 'UEM' group
default['easy_travel']['autostartScenarioGroup'] = 'UEM'
default['easy_travel']['autostartScenario'] = 'Standard'

#TODO this is only description where Easy Travel is installed on Windows; it is not destination folder (this attribute do not change installation folder)
#One way to get installation folder is parse C:\chef\cache\easy_travel\easy_travel_install.log file and find following properties:
#Property(S): APPDIR = C:\Program Files\dynaTrace\easyTravel (x64)\
#Property(S): TARGETDIR = C:\Program Files\dynaTrace\easyTravel (x64)\
#Property(S): resources_DIR = C:\Program Files\dynaTrace\easyTravel (x64)\resources\
#Property(S): weblauncher_DIR = C:\Program Files\dynaTrace\easyTravel (x64)\weblauncher\
# Different way is investigation how to pass parameter with destination folder to msi file.
#default['easy_travel']['windows']['installer']['folder'] = 'C:\\Program Files\\dynaTrace\\easyTravel (x64)\\'
default['easy_travel']['windows']['installer']['folder'] = 'C:/Program Files/dynaTrace/easyTravel (x64)'

#TODO remove this entry
#place where user specific folders and configuration is placed
default['easy_travel']['windows']['installer']['user_folder'] = 'C:\\Users\\Administrator'
