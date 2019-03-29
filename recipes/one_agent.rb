# frozen_string_literal: true

#
# Cookbook Name:: dynatrace
# Recipes:: one_agent
#
# Copyright 2017, Dynatrace
#

include_recipe 'dynatrace-appmon::prerequisites'
include_recipe 'dynatrace-appmon::dynatrace_user'

name = 'Dynatrace One Agent'

if platform_family?('debian', 'fedora', 'rhel')
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
  installer_file_url = node['dynatrace']['one_agent']['linux']['installer']['file_url']
  installer_prefix_dir = node['dynatrace']['one_agent']['linux']['installer']['prefix_dir']
  installer_file_name = node['dynatrace']['one_agent']['linux']['installer']['file_name']
  installer_file_path = "#{installer_cache_dir}/#{installer_file_name}"
elsif platform_family?('windows')
  installer_cache_dir = "#{Chef::Config['file_cache_path']}\\dynatrace"
  installer_install_dir = node['dynatrace']['one_agent']['windows']['installer']['install_dir']
  installer_file_name = node['dynatrace']['one_agent']['windows']['installer']['file_name']
  installer_file_url = node['dynatrace']['one_agent']['windows']['installer']['file_url']
  installer_file_path = "#{installer_cache_dir}\\#{installer_file_name}"
else
  raise 'Unsupported platform family.'
end

directory "Create the installer cache directory #{installer_cache_dir}" do
  path   installer_cache_dir
  action :create
end

ruby_block "Check if #{name} already installed" do
  block do
    node.normal['dynatrace']['one_agent']['installation']['is_required'] = Dynatrace::PackageHelpers.requires_installation?(installer_prefix_dir, installer_file_path, 'agent/bin/linux-x86-32/liboneagentloader.so', type = :tar)
  end
  not_if { platform_family?('windows') }
end

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']
fresh_installer_action = "#{name} installer changed"

dynatrace_appmon_copy_or_download_file "Downloading One Agent installer: #{installer_file_url}" do
  file_name       installer_file_name
  file_url        installer_file_url
  path            installer_file_path
  dynatrace_owner dynatrace_owner
  dynatrace_group dynatrace_group
  notifies :run, "ruby_block[#{fresh_installer_action}]", :immediately
end

ruby_block fresh_installer_action.to_s do
  block do
    raise "The downloaded installer package would overwrite existing installation of the #{name}."
  end
  action :nothing
  not_if { platform_family?('windows') || node['dynatrace']['one_agent']['installation']['is_required'] }
end

if platform_family?('debian', 'fedora', 'rhel')

  directory "Create the installation directory #{installer_prefix_dir}" do
    path      installer_prefix_dir
    owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
    group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
    recursive true
    action    :create
  end

  symlink_name = node['dynatrace']['one_agent']['linux']['installer']['symlink_name']

  dynatrace_appmon_run_tar_installer name.to_s do
    installer_path       installer_file_path
    installer_prefix_dir installer_prefix_dir
    symlink_name         symlink_name
    dynatrace_owner      dynatrace_owner
    dynatrace_group      dynatrace_group
    only_if { node['dynatrace']['one_agent']['installation']['is_required'] }
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
    command "powershell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned -InputFormat None -File InstallMSI.ps1 -InstallPath \"#{installer_install_dir}\" -Installer \"#{installer_file_path}\""
    cwd     dynatrace_powershell_scripts
  end
end
