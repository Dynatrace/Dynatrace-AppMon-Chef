#
# Cookbook Name:: dynatrace
# Attributes:: java
#
# Copyright 2016, Dynatrace
#

default['dynatrace']['java']['install_jdk'] = true

# Dynatrace packages require JDK 7 but the 'java' cookbook by default installs JDK 6
default['java']['jdk_version'] = '7'
