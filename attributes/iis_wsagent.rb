# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Attributes:: iis_wsagent
#
# Copyright 2015, Dynatrace
#

# 32 or 64
default['dynatrace']['iis_wsagent']['dynatrace']['agentlib']['bitsize'] = '64'

# The path to the Dynatrace installation.
default['dynatrace']['iis_wsagent']['dynatrace']['install_dir'] = 'C:\Program Files (x86)\Dynatrace'
