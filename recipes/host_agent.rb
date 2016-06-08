#
# Cookbook Name:: dynatrace
# Recipes:: host_agent
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::upgrade_system'

name = 'Host Agent'
														#for AWS it can be:
node_platform = node['platform']							#	"amazon"
node_platform_version = node['platform_version']			#	"2016.03"
node_os = node['os']										#	"linux"
node_os_version = node['os_version']						#	"4.4.5-15.26.amzn1.x86_64"
node_kernel_machine = node['kernel']['machine']				#	"x86_64"
node_kernel_processor = node['kernel']['processor']			#	"x86_64"
puts 'Platform:' + node_platform + "  version:" + node_platform_version + "  os:" + node_os.to_s + "  os_version:" + node_os_version.to_s + '  machine:' + node_kernel_machine.to_s
could_be_installed = false

#determine source tar file to execute
tar_file = node['dynatrace']['host_agent']['installer']['file_name']
if platform_family?('rhel') and node_kernel_machine == 'x86_64'

  tar_file += "linux-x86-"

	if node['host_agent']['installer']['bitsize'] == '64'
		#the only platform for which we are able to test this recipe
		could_be_installed = true
		tar_file += "64"
	else
		tar_file += "32"
	end
else
	# Unsupported
	log 'Unsupported platform yet'
	
	#have to change this verificatin (do not use platform_family)
	#we need to have map platform_family -> name of source tar file
	#
#	if platform_family?('aix-ppc', 'hpux-ia64', 'linux-ppc', 'linux-s390', 'linux-s390x', 'linux-x86', 'solaris-sparc', 'solaris-x86')
#		if platform_family?('linux-s390', 'linux-s390x')
#			#tar file format:
#			#	dynatrace-hostagent-linux-s390.tar
#			#	dynatrace-hostagent-linux-s390x.tar		
#			if platform_family?('linux-s390x')
#				tar_file = tar_file + "linux-s390x"
#			else
#				tar_file = tar_file + "linux-s390"
#			end
#		else
#			#tar file format:
#			#	dynatrace-hostagent-linux-ppc-32.tar
#			#	dynatrace-hostagent-linux-ppc-64.tar
#			if platform_family?('aix-ppc')
#				tar_file = tar_file + "aix-ppc"
#			elsif platform_family?('hpux-ia64')
#				tar_file = tar_file + "hpux-ia64"
#			elsif platform_family?('linux-ppc')
#				tar_file = tar_file + "linux-ppc"
#			elsif platform_family?('linux-x86')
#				tar_file = tar_file + "linux-x86"
#			elsif platform_family?('solaris-sparc')
#				tar_file = tar_file + "solaris-sparc"
#			elsif platform_family?('solaris-x86')
#				tar_file = tar_file + "solaris-x86"
#			else
#				tar_file = tar_file + "linux"
#			end
#		end
#	end
end

tar_file += ".tar"
log 'Installer file: ' + tar_file

installer_prefix_dir = node['dynatrace']['host_agent']['installer']['prefix_dir']
installer_file_name  = tar_file
installer_file_url   = node['dynatrace']['host_agent']['installer']['file_url'] + tar_file
installer_cache_dir = "#{Chef::Config['file_cache_path']}/host_agent"
installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
dynatrace_owner = node['dynatrace']['owner']
dynatrace_group = node['dynatrace']['group']
host_agent_name = node['dynatrace']['host_agent']['host_agent_name']
host_agent_collector = node['dynatrace']['host_agent']['collector']

#if could_be_installed
#  #verification if Host Agent is already installed
#  fileExists = "/etc/init.d/dynaTraceHostagent"
#  if File.exist?(fileExists)
#    # cannot install host_agent because is alredy installed
#	log 'Host Agent file' + fileExists + ' exists. Host Agent will not be installed. Run host_agent_uninstall recipe first. Be careful - you will lost your configuration.'
#	could_be_installed = false
#  end
#end

if could_be_installed
  if could_be_installed
    #verification if Host Agent is already installed
    fileExists = "/etc/init.d/dynaTraceHostagent"
    if File.exist?(fileExists)
      # Host Agent is already installed
      puts 'Host Agent file' + fileExists + ' exists. Host Agent will override existing installation.'
    end
  end

	puts 'Initializing directories'
	#creating tmp installer directory
	directory "Create temporrary installer cache directory: #{installer_cache_dir}" do
	  path   installer_cache_dir
	  action :create
	end
		
  puts 'Create user group: ' + dynatrace_group
  group dynatrace_group do
    action :create
    append true
  end
  
  puts 'Create user: ' + dynatrace_owner
  user dynatrace_owner do
    gid dynatrace_group
    supports :manage_home => true
    home "/home/#{dynatrace_owner}"
    shell "/bin/bash"
    system true
  end	

  puts 'download installation tar file'
	dynatrace_copy_or_download_file "Downloading installation tar file: #{installer_file_name}" do
	  file_name       installer_file_name
	  file_url        installer_file_url  
	  path            installer_path
	  dynatrace_owner dynatrace_owner
	  dynatrace_group dynatrace_group
	end

	#creating installation directory. It usually exists, default is /opt
	directory "Create the installation directory #{installer_prefix_dir}" do
	  path      installer_prefix_dir
	  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
	  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
	  recursive true
	  action    :create
	end

	#perform installation of host_agent
	dynatrace_run_tar_installer_for_hostagent "Installing #{name}" do
		installer_prefix_dir installer_prefix_dir
		installer_path       installer_path
		dynatrace_owner      dynatrace_owner
		dynatrace_group      dynatrace_group
		host_agent_name 	 host_agent_name
		host_agent_collector host_agent_collector
	end
end
