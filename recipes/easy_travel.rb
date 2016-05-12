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
name = 'Easy Travel'

installer_bitsize = node['easy_travel']['installer']['bitsize']
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
	  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
	  dynatrace_owner      dynatrace_owner
	  dynatrace_group      dynatrace_group
	  only_if { node[:easy_travel][:installation][:is_required] }
	end
  
  ruby_block "Inject Web Server agents into #{name}" do
    block do 
      #TODO! does not work yet
      #Dynatrace::Helpers.file_replace_line("#{installer_prefix_dir}/easytravel/resources/easyTravelConfig.properties", "(config.frontendJavaopts=.*)", "\1 TEST")
      #Dynatrace::Helpers.file_replace_line("#{installer_prefix_dir}/easytravel/resources/easyTravelConfig.properties", "(config.backendJavaopts=.*)", "\1 TEST")
    end
  end
  
  execute "Start installed program #{name}" do
    command "#{installer_prefix_dir}/easytravel/weblauncher/weblauncher.sh&"
  end
  
end
