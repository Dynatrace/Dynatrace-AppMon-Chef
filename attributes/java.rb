#
# Cookbook Name:: dynatrace
# Attributes:: java
#
# Copyright 2016, Dynatrace
#

default['dynatrace']['java']['install_jdk'] = true

override['java']['jdk_version'] = '7'
