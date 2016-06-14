#
# Cookbook Name:: dynatrace
# Recipes:: wsagent_package_uninstall
#
# Copyright 2015, Dynatrace
#

require 'json'

#include_recipe 'dynatrace::helpers'

name = 'Dynatrace WebServer Agent'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['wsagent_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['wsagent_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['wsagent_package']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  service = 'dynaTraceWebServerAgent'
  init_scripts = services = [service]
elsif platform_family?('windows')
  installer_install_dir = node['dynatrace']['wsagent_package']['windows']['installer']['install_dir']
  installer_file_name   = node['dynatrace']['wsagent_package']['windows']['installer']['file_name']
  installer_file_url    = node['dynatrace']['wsagent_package']['windows']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"
  installer_path      = "#{installer_cache_dir}\\#{installer_file_name}"
else
  raise "Unsupported platform family."
end

directory "Delete the installer cache directory" do
  path   installer_cache_dir
  recursive true
  action :delete
end

if platform_family?('debian', 'fedora', 'rhel')
  service "#{name}" do
    service_name service
    supports     :status => true
    action [:stop, :disable]
  end

  file "#{installer_prefix_dir}/dynatrace/agent/conf/dtwsagent.ini" do
    action :delete
  end  
  
  link '/etc/init.d/dynaTraceWebServerAgent' do
    action :delete
    only_if "test -L /etc/init.d/dynaTraceWebServerAgent"
  end      
      
  
elsif platform_family?('windows')
  dynatrace_powershell_scripts_project = "#{installer_cache_dir}\\Dynatrace-Powershell"
  dynatrace_powershell_scripts = "#{dynatrace_powershell_scripts_project}\\scripts"

#  remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
#    source 'Dynatrace-Powershell'
#    path   dynatrace_powershell_scripts_project
#    action :create
#  end

#  execute "Install the Dynatrace WebServer Agent package" do
#    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallMSI.ps1 -InstallPath \"#{installer_install_dir}\" -Installer \"#{installer_path}\""
#    cwd     dynatrace_powershell_scripts
#  end

#  wsagent_service_config = {
#    :Name     => node['dynatrace']['wsagent_package']['agent_name'],
#    :Server   => "#{node['dynatrace']['wsagent_package']['collector_hostname']}:#{node['dynatrace']['wsagent_package']['collector_port']}",
#    :Loglevel => 'info'
#  }.to_json.gsub('"', "\\\\\"")

#  execute "Install the Dynatrace WebServer Agent service" do
#    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallWSAgentService.ps1 -InstallPath \"#{installer_install_dir}\" -JSONConfig \"#{wsagent_service_config}\""
#    cwd     dynatrace_powershell_scripts
#  end

  remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
    source 'Dynatrace-Powershell'
    path   dynatrace_powershell_scripts_project
    recursive true
    action :delete
  end

end
