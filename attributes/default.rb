# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Attributes:: default
#
# Copyright 2015, Dynatrace
#

# The system user that owns the Dynatrace installation.
default['dynatrace']['owner'] = 'dynatrace'

# The system user's group that owns the Dynatrace installation.
default['dynatrace']['group'] = 'dynatrace'

# default folder for chef embedded folder (just in case for those machines where Rubby is available in version < 2.1 only)
default['chef_embedded'] = '/opt/chef/embedded/bin/'
