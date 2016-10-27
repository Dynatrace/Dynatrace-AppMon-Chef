#
# Cookbook Name:: dynatrace
# Recipes:: agents_package
#
# Copyright 2015-2016, Dynatrace
#

include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::java'

name = 'Dynatrace Agents Package'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']
  installer_file_name  = node['dynatrace']['agents_package']['linux']['installer']['file_name']
  installer_file_url   = node['dynatrace']['agents_package']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
elsif platform_family?('windows')
  installer_install_dir = node['dynatrace']['agents_package']['windows']['installer']['install_dir']
  installer_file_name   = node['dynatrace']['agents_package']['windows']['installer']['file_name']
  installer_file_url    = node['dynatrace']['agents_package']['windows']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"
  installer_path      = "#{installer_cache_dir}\\#{installer_file_name}"
else
  raise 'Unsupported platform family.'
end

include_recipe 'dynatrace::dynatrace_user'

directory 'Create the installer cache directory' do
  path   installer_cache_dir
  action :create
end

dynatrace_copy_or_download_file name.to_s do
  file_name       installer_file_name
  file_url        installer_file_url
  path            installer_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
end

if platform_family?('debian', 'fedora', 'rhel')
  ruby_block name.to_s do
    block do
      kernel = node['kernel']['machine'].include?('64') ? '64' : ''
      node.set[:dynatrace][:agents_package][:installation][:is_required] = Dynatrace::PackageHelpers.requires_installation?(installer_prefix_dir, installer_path, "agent/lib#{kernel}/libdtagent.so", type = :jar)
    end
  end

  directory "Create the installation directory #{installer_prefix_dir}" do
    path      installer_prefix_dir
    owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
    group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
    recursive true
    action    :create
  end

  dynatrace_run_jar_installer name.to_s do
    installer_path       installer_path
    installer_prefix_dir installer_prefix_dir
    dynatrace_owner      dynatrace_owner
    dynatrace_group      dynatrace_group
    only_if { node[:dynatrace][:agents_package][:installation][:is_required] }
  end
elsif platform_family?('windows')
  dynatrace_powershell_scripts_project = "#{installer_cache_dir}\\Dynatrace-Powershell"
  dynatrace_powershell_scripts = "#{dynatrace_powershell_scripts_project}\\scripts"

  remote_directory "Copy Dynatrace PowerShell scripts to #{dynatrace_powershell_scripts_project}" do
    source 'Dynatrace-Powershell'
    path   dynatrace_powershell_scripts_project
    action :create
  end

  execute 'Install the Dynatrace Agents package' do
    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallMSI.ps1 -InstallPath \"#{installer_install_dir}\" -Installer \"#{installer_path}\""
    cwd     dynatrace_powershell_scripts
  end
end
