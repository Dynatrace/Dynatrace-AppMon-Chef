#
# Cookbook Name:: dynatrace
# Recipes:: wsagent_package
#
# Copyright 2015-2016, Dynatrace
#

require 'json'

include_recipe 'dynatrace-appmon::prerequisites'

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
  raise 'Unsupported platform family.'
end

if platform_family?('debian', 'fedora', 'rhel')
  include_recipe 'dynatrace-appmon::dynatrace_user'
end

directory 'Create the installer cache directory' do
  path   installer_cache_dir
  action :create
end

dynatrace_appmon_copy_or_download_file name.to_s do
  file_name       installer_file_name
  file_url        installer_file_url
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
end

if platform_family?('debian', 'fedora', 'rhel')
  directory "Create the installation directory #{installer_prefix_dir}" do
    path      installer_prefix_dir
    owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
    group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
    recursive true
    action    :create
  end

  ruby_block "Check if #{name} already installed" do
    block do
      kernel = node['kernel']['machine'].include?('64') ? '64' : ''
      node.normal['dynatrace']['wsagent_package']['installation']['is_required'] = \
        Dynatrace::PackageHelpers.requires_installation?(installer_prefix_dir, installer_path, "agent/lib#{kernel}/dtwsagent", type = :tar)
    end
  end

  dynatrace_appmon_run_tar_installer name.to_s do
    installer_path       installer_path
    installer_prefix_dir installer_prefix_dir
    dynatrace_owner      dynatrace_owner
    dynatrace_group      dynatrace_group
    only_if { node['dynatrace']['wsagent_package']['installation']['is_required'] }
  end

  dynatrace_appmon_configure_init_scripts name.to_s do
    installer_prefix_dir installer_prefix_dir
    scripts              init_scripts
    dynatrace_owner      dynatrace_owner
    dynatrace_group      dynatrace_group
    notifies             :restart, "service[#{name}]", :immediately
  end

  template "Configure and copy the #{name}'s 'dtwsagent.ini' file" do
    source 'wsagent_package/dtwsagent.ini.erb'
    cookbook 'dynatrace-appmon'
    path   "#{installer_prefix_dir}/dynatrace/agent/conf/dtwsagent.ini"
    owner  dynatrace_owner
    group  dynatrace_group
    mode   '0644'
    variables(:agent_name => node['dynatrace']['wsagent_package']['agent_name'],
              :collector_hostname => node['dynatrace']['wsagent_package']['collector_hostname'],
              :collector_port => node['dynatrace']['wsagent_package']['collector_port'])
    action   :create
    notifies :restart, "service[#{name}]", :immediately
  end

  the_provider = nil
  case node['dynatrace']['service']['provider']
  when 'Init'
    the_provider = Chef::Provider::Service::Init
    the_action = [:start]
  else
    the_action = [:start, :enable]
  end

  service name.to_s do
    provider the_provider
    service_name service
    # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
    supports     :status => true
    action       the_action
  end
elsif platform_family?('windows')
  dynatrace_powershell_scripts_project = "#{installer_cache_dir}\\Dynatrace-Powershell"
  dynatrace_powershell_scripts = "#{dynatrace_powershell_scripts_project}\\scripts"

  remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
    source 'Dynatrace-Powershell'
    path   dynatrace_powershell_scripts_project
    action :create
  end

  execute 'Install the Dynatrace WebServer Agent package' do
    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallMSI.ps1 -InstallPath \"#{installer_install_dir}\" -Installer \"#{installer_path}\""
    cwd     dynatrace_powershell_scripts
  end

  wsagent_service_config = {
    :Name     => node['dynatrace']['wsagent_package']['agent_name'],
    :Server   => "#{node['dynatrace']['wsagent_package']['collector_hostname']}:#{node['dynatrace']['wsagent_package']['collector_port']}",
    :Loglevel => 'info'
  }.to_json.gsub('"', '\\\\"')

  execute 'Install the Dynatrace WebServer Agent service' do
    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallWSAgentService.ps1 -InstallPath \"#{installer_install_dir}\" -JSONConfig \"#{wsagent_service_config}\""
    cwd     dynatrace_powershell_scripts
  end
end
