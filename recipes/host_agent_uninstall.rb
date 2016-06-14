#
# Cookbook Name:: dynatrace
# Recipes:: host_agent_uninstall
#
# Copyright 2016, Dynatrace
#
name = 'uninstall Host Agent'
include_recipe 'dynatrace::node_info'

installer_prefix_dir = node['dynatrace']['host_agent']['installer']['prefix_dir']
installer_cache_dir = "#{Chef::Config['file_cache_path']}/host_agent"

log 'installer_prefix_dir=' + installer_prefix_dir

if platform_family?('rhel')
	##########################################################
	# stop Host Agent process
	
  # stop dynaTraceHostagent 
  service 'dynaTraceHostagent' do
    action [:stop, :disable]
  end
  
	fileExists = "/etc/init.d/dynaTraceHostagent"
	if File.exist?(fileExists)
		cmd2exec = "/etc/init.d/dynaTraceHostagent stop"
		%x[ #{cmd2exec} ]
	end
	##########################################################
	#delete cache directory if exists
	dir2delete = installer_cache_dir
	
	# Test if directory is empty.'
	if Dir.exist?(dir2delete) && !(Dir.entries(dir2delete) - %w{ . .. }).empty? 
		# directory already exists and will be deleted
		log 'Destination directory:' + dir2delete + ' will be deleted.'
		directory "Delete the installation directory #{dir2delete}" do
			path      dir2delete
			recursive true
			action    :delete
		end
	end
  
	if File.exist?(fileExists)
		cmd2exec = "rm -r -f /etc/init.d/dynaTraceHostagent"
		log cmd2exec
		%x[ #{cmd2exec} ]
	end
  
	#remove selected files
  cmd2exec = "rm -rf /opt/dynatrace/init.d/dynaTraceHostagent"
  log cmd2exec
  %x[ #{cmd2exec} ]
  
	cmd2exec = "rm -rf /opt/dynatrace/agent/conf/dthostagent.ini"
	log cmd2exec
	%x[ #{cmd2exec} ]
	
  cmd2exec = "rm -rf /opt/dynatrace/agent/conf/dthostagent.ini.old"
  log cmd2exec
  %x[ #{cmd2exec} ]
  
  cmd2exec = "rm -rf /opt/dynatrace/agent/conf/dthostagent.ini_backup"
  log cmd2exec
  %x[ #{cmd2exec} ]
  
  #TODO maybe it is possible remove more - note about conflicts with dynatrace server and different agents
	
else
	# Unsupported platform
	log 'Unsuppored platform. Host Agent will not be uninstalled.'
end
