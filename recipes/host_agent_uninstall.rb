#
# Cookbook Name:: dynatrace
# Recipes:: host_agent_uninstall
#
# Copyright 2016, Dynatrace
#
name = 'uninstall Host Agent'
															#for AWS it can be:
node_platform = node['platform']							#	"amazon"
node_platform_version = node['platform_version']			#	"2016.03"
node_os = node['os']										#	"linux"
node_os_version = node['os_version']						#	"4.4.5-15.26.amzn1.x86_64"
node_kernel_machine = node['kernel']['machine']				#	"x86_64"
node_kernel_processor = node['kernel']['processor']			#	"x86_64"

log 'Platform:' + node_platform + "  version:" + node_platform_version + "  os:" + node_os.to_s + "  os_version:" + node_os_version.to_s + '  machine:' + node_kernel_machine.to_s

installer_prefix_dir = node['dynatrace']['host_agent']['installer']['prefix_dir']
installer_cache_dir = "#{Chef::Config['file_cache_path']}/host_agent"

log 'installer_prefix_dir=' + installer_prefix_dir

if platform_family?('rhel')
	##########################################################
	# stop Host Agent process
	
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
  
	cmd2exec = "rm -r -f /etc/init.d/dynaTraceHostagent"
	%x[ #{cmd2exec} ]

	#remove directory using symlink
	cmd2exec = "rm -rf \"$(readlink /opt/dynatrace)\""
	log cmd2exec
	%x[ #{cmd2exec} ]

	#remove symlink
	cmd2exec = "rm -rf /opt/dynatrace"
	log cmd2exec
	%x[ #{cmd2exec} ]
else
	# Unsupported platform
	log 'Unsuppored platform. Host Agent will not be uninstalled.'
end
