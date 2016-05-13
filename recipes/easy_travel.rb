#
# Cookbook Name:: easy_travel
# Recipes:: dynatrace
# will install Easy Travel
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'
include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'
include_recipe 'dynatrace::agents_package'
name = 'Easy Travel'

dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']

# assume that we can install Easy Travel, it will be verified now
could_be_installed = true

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['easy_travel']['linux']['installer']['prefix_dir']
  installer_file_name  = node['easy_travel']['linux']['installer']['file_name']
  installer_file_url   = node['easy_travel']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/easy_travel"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

  dir2delete = installer_prefix_dir + "/easytravel"
  log 'Test if destination directory: ' + dir2delete + ' is empty.'
  if Dir.exist?(dir2delete) && !(Dir.entries(dir2delete) - %w{ . .. }).empty? 
    # cannot install Easy Travel because of destination directory already exists
	log 'Destination directory:' + dir2delete + ' exists and is NOT empty. Easy Travel will not be installed. Run easy_travel_uninstall recipe first. Be careful - you will lost your configuration.'
	could_be_installed = false
  end
  
else
	# Unsupported platform
	could_be_installed = false
	log 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be installed.'
end

if could_be_installed == true then
	#creating tmp installer directory
	directory "Create the installer cache directory: #{installer_cache_dir}" do
	  path   installer_cache_dir
	  action :create
	end

	#download installation jar file
	dynatrace_copy_or_download_file "Downloading installation jar file: #{name}" do
	  file_name       installer_file_name
	  file_url        installer_file_url  
	  path            installer_path
	  dynatrace_owner dynatrace_owner
	  dynatrace_group dynatrace_group
	end

	ruby_block "#{name}" do
	  block do
		node.set[:easy_travel][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, '', type=:jar)
	  end
	end

	#creating installation directory
	directory "Create the installation directory #{installer_prefix_dir}" do
	  path      installer_prefix_dir
	  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
	  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
	  recursive true
	  action    :create
	  only_if { node[:easy_travel][:installation][:is_required] }
	end

	#perform installation of Easy Travel
	dynatrace_run_jar_installer "#{name}" do
	  installer_path       installer_path
	  installer_prefix_dir installer_prefix_dir
	  dynatrace_owner      dynatrace_owner
	  dynatrace_group      dynatrace_group
	  only_if { node[:easy_travel][:installation][:is_required] }
	end
  
  config_path = "#{installer_prefix_dir}/easytravel/resources/easyTravelConfig.properties"
  config_path_training = "#{installer_prefix_dir}/easytravel/resources/easyTravelTrainingConfig.properties"
  
  #switch to training mode
  remote_file  'Switch to training mode' do
    path config_path
    source "file://#{config_path_training}"
  end
  
  agent_path = node['dynatrace']['java_agent']['linux']['x86']['agent_path']
  
  dynatrace_java_agent 'backendJavaAgent' do
    agent_path agent_path
  end

  dynatrace_java_agent 'frontendJavaAgent' do
    agent_path agent_path
  end
  
  ruby_block "Inject Java agents into #{name}" do
    block do 
      commonOpts = node['easy_travel']['common_javaopts']
      backendAgentOpts = node['dynatrace']['java_agent']['javaopts']['backendJavaAgent'].gsub(/,/, ",,")
      frontendAgentOpts = node['dynatrace']['java_agent']['javaopts']['frontendJavaAgent'].gsub(/,/, ",,")
      backendJavaOpts = "#{commonOpts},#{backendAgentOpts}"
      frontendJavaOpts = "#{commonOpts},#{frontendAgentOpts}"
      Dynatrace::Helpers.file_replace_line(config_path, "(config.backendJavaopts=.*)", "config.backendJavaopts=#{backendJavaOpts}")
      Dynatrace::Helpers.file_replace_line(config_path, "(config.frontendJavaopts=.*)", "config.frontendJavaopts=#{frontendJavaOpts}")
    end
  end
  
  execute "Start installed program #{name}" do
    command "#{installer_prefix_dir}/easytravel/weblauncher/weblauncher.sh&"
  end
  
end
