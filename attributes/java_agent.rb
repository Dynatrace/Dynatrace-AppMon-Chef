#
# Cookbook Name:: dynatrace
# Attributes:: java_agent
#
# Copyright 2015, Dynatrace
#

# The name of the environment variable to be used for Dynatrace Agent injection.
default['dynatrace']['java_agent']['env_var']['name'] = 'JAVA_OPTS'

# The name of the file to be modified.
default['dynatrace']['java_agent']['env_var']['file_name'] = nil

# The name of the Dynatrace Agent as it appears in the Dynatrace Server.
default['dynatrace']['java_agent']['name'] = 'java-agent'

# The location of the collector the Dynatrace Agent shall connect to.
default['dynatrace']['java_agent']['collector']['hostname'] = 'localhost'

# The port on the collector the Dynatrace Agent shall connect to.
default['dynatrace']['java_agent']['collector']['port'] = '9998'

# The path to the Dynatrace Agent libary.
default['dynatrace']['java_agent']['linux']['agent_path'] = '/opt/dynatrace/agent/lib64/libdtagent.so'
