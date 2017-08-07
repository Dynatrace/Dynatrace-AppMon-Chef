#
# Cookbook Name:: dynatrace
# Recipes:: dotnet_agent
#
# Copyright 2015-2016, Dynatrace
#

require 'json'

dynatrace_agentlib_bitsize = node['dynatrace']['iis_wsagent']['dynatrace']['agentlib']['bitsize']
dynatrace_install_dir      = node['dynatrace']['iis_wsagent']['dynatrace']['install_dir']

agent_name         = node['dynatrace']['dotnet_agent']['agent_name']
collector_hostname = node['dynatrace']['dotnet_agent']['collector_hostname']
collector_port     = node['dynatrace']['dotnet_agent']['collector_port']
process_list       = node['dynatrace']['dotnet_agent']['process_list']

raise 'Unsupported platform family.' unless platform_family?('windows')

installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"

dynatrace_powershell_scripts_project = "#{installer_cache_dir}\\Dynatrace-Powershell"
dynatrace_powershell_scripts         = "#{dynatrace_powershell_scripts_project}\\scripts"

include_recipe 'dynatrace-appmon::agents_package'

remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
  source 'Dynatrace-Powershell'
  path   dynatrace_powershell_scripts_project
  action :create
end

dotnet_process_list = process_list.to_json.gsub('"', '\\\\"')

execute 'Install the Dynatrace WebServer Agent in IIS' do
  command 'powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File '\
          "InstallDotNetAgent.ps1 -InstallPath \"#{dynatrace_install_dir}\" -AgentName #{agent_name} "\
          "-CollectorHost #{collector_hostname}:#{collector_port} " \
          "#{dynatrace_agentlib_bitsize == '64' ? '-Use64Bit' : ''} -JSONProcessList \"#{dotnet_process_list}\" "\
          '> C:\\Windows\\Temp\\1.txt'
  cwd     dynatrace_powershell_scripts
end
