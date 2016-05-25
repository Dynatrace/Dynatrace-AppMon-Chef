#
# Cookbook Name:: easy_travel_uninstall
# Recipes:: dynatrace
# will uninstall Easy Travel
# NOTE: Be careful - you will lost your Easy Travel configuration!!!
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'

include_recipe 'dynatrace::dynatrace_user'
name = 'Easy Travel'

if platform_family?('debian', 'fedora', 'rhel')

  ruby_block "Stop any running instance of #{name}" do
    block do
      Dynatrace::Helpers.stop_processes(node['easy_travel']['proc_pattern'], node['platform_family'])
    end
  end

	installer_prefix_dir = node['easy_travel']['linux']['installer']['prefix_dir']
	installer_file_name  = node['easy_travel']['linux']['installer']['file_name']
	link_name = node['easy_travel']['linux']['installer']['link']
	dir2delete = installer_prefix_dir + '/' + link_name
	
	# Test if destination directory is empty.'
	if Dir.exist?(dir2delete) && !(Dir.entries(dir2delete) - %w{ . .. }).empty? 
		# destination directory already exists and will be deleted
		log 'Destination directory:' + dir2delete + ' exists and is NOT empty. Easy Travel will be uninstalled. You will lost your configuration.'

#		directory "Delete the installation directory #{installer_prefix_dir}" do
#			path      dir2delete
#			recursive true
#			action    :delete
#		end

		#remove directory using symlink
		cmd2exec = "rm -rf \"$(readlink /opt/#{link_name})\""
		log cmd2exec
		%x[ #{cmd2exec} ]

		#remove symlink
		cmd2exec = "rm -rf /opt/#{link_name}"
		log cmd2exec
		%x[ #{cmd2exec} ]

	else
		log 'Destination directory:' + dir2delete + ' not exists. It looks loke Easy Travel is not installed.'
	end
  
else
	# Unsupported platform
	log 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be uninstalled.'
end



