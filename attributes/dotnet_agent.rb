#
# Cookbook Name:: dynatrace
# Attributes:: dotnet_agent
#
# Copyright 2015, Dynatrace
#

# 32 or 64
default['dynatrace']['dotnet_agent']['dynatrace']['agentlib']['bitsize'] = '64'

# The path to the Dynatrace installation.
default['dynatrace']['dotnet_agent']['dynatrace']['install_dir'] = 'C:\Program Files\Dynatrace'

# The name the Dynatrace .NET Agent as it appears in the Dynatrace Server.
default['dynatrace']['dotnet_agent']['agent_name'] = 'dotnetagent'

# The location of the Dynatrace Collector the .NET Agent shall connect to.
default['dynatrace']['dotnet_agent']['collector_hostname'] = 'localhost'

# The port on the Dynatrace Collector the .NET Agent shall connect to.
default['dynatrace']['dotnet_agent']['collector_port'] = '9998'

# The list of processes (including any arguments) the .NET Agent shall be monitoring.
default['dynatrace']['dotnet_agent']['process_list'] = []
