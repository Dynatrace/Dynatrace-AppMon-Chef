#
# Cookbook Name:: dynatrace
# Recipes:: iis_wsagent
#
# Copyright 2015, Dynatrace
#

name = 'Dynatrace IIS WebServer Agent'

dynatrace_agentlib_bitsize = node['dynatrace']['iis_wsagent']['dynatrace']['agentlib']['bitsize']
dynatrace_install_dir      = node['dynatrace']['iis_wsagent']['dynatrace']['install_dir']

raise 'Unsupported platform family.' unless platform_family?('windows')

installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"

dynatrace_powershell_scripts_project = "#{installer_cache_dir}\\Dynatrace-Powershell"
dynatrace_powershell_scripts         = "#{dynatrace_powershell_scripts_project}\\scripts"

include_recipe 'dynatrace-appmon::wsagent_package'

remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
  source 'Dynatrace-Powershell'
  path   dynatrace_powershell_scripts_project
  action :create
end

execute 'Install the Dynatrace WebServer Agent in IIS' do
  command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallWSAgentModuleIIS.ps1 -InstallPath \"#{dynatrace_install_dir}\" #{dynatrace_agentlib_bitsize == '64' ? '-Use64Bit' : ''} -ForceIISReset"
  cwd     dynatrace_powershell_scripts
end
