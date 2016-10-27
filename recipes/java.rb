#
# Cookbook Name:: dynatrace
# Recipes:: java
#
# Copyright 2016, Dynatrace
#

include_recipe 'java' if node['dynatrace']['java']['install_jdk']
