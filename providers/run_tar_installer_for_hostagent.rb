#
# Cookbook Name:: dynatrace
# Providers:: run_tar_installer_for_hostagent
#
# Copyright 2016, Dynatrace
#

action :run do
  install_dir = ::File.dirname(new_resource.installer_path)				#/var/chef/cache/host_agent
  base_name = ::File.basename(new_resource.installer_path)				#dynatrace-hostagent-linux-x86-64.tar
  
  execute "Extract the #{new_resource.name} tarball" do
    command "tar xvf #{new_resource.installer_path}"
    cwd     install_dir
  end

  execute "Remove the installer tar file: #{new_resource.installer_path}" do
    command "rm -f #{new_resource.installer_path}"
    cwd     new_resource.installer_prefix_dir
  end
  
  ruby_block "Make the installation" do
    block do
  		installation_path_part = get_folder_name(install_dir)
  		
  		puts '#####: modify ' + install_dir + '/' + installation_path_part + '/agent/conf/dthostagent.ini  host_agent_name=' + new_resource.host_agent_name + '  collector=' + new_resource.host_agent_collector + " :#####"
  		modify_ini_file("#{install_dir}/#{installation_path_part}/agent/conf/dthostagent.ini", new_resource.host_agent_name, new_resource.host_agent_collector)
  		
  		exec_cmd("cp #{install_dir}/#{installation_path_part}/init.d/dynaTraceHostagent /etc/init.d/")
  		# remove init.d from tmp folder
      exec_cmd("rm -rf #{install_dir}/#{installation_path_part}/init.d")
  
      installation_path = "#{new_resource.installer_prefix_dir}/#{installation_path_part}"
  		exec_cmd(cp_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{installation_path_part}", new_resource.installer_prefix_dir))
  
   		exec_cmd(get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group))
  		link "Create a symlink of the #{installation_path} installation to #{new_resource.installer_prefix_dir}/dynatrace" do
  			target_file "#{new_resource.installer_prefix_dir}/dynatrace"
  			to "#{installation_path}"
  		end
      exec_cmd(get_chown_link_cmd(new_resource.installer_prefix_dir + "/dynatrace", new_resource.dynatrace_owner, new_resource.dynatrace_group))
	  end
  end

#  execute "execute: chkconfig add dynaTraceHostagent" do
#    command "chkconfig --add /etc/init.d/dynaTraceHostagent"
#  end

  service 'dynaTraceHostagent' do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

  # Workaround: Manualy start the service as it won't be started 
  # automatically due to a bug in the dynaTraceHostagent script
  execute "start dynaTraceHostagent" do
    command "/etc/init.d/dynaTraceHostagent start"
    user new_resource.dynatrace_owner
  end
 
end


def get_chown_link_cmd(dir, owner, group)
  return "chown -h #{owner}:#{group} #{dir}"
end

def get_chown_recursively_cmd(dir, owner, group)
  return "chown -R #{owner}:#{group} #{dir}"
end

def cp_install_dir_cmd(src, dest)
  return "cp -R #{src} #{dest}"
end

def get_folder_name(dir)
	%x[ #{"ls #{dir}"} ].each_line do |item|
		return item.gsub("\n",'')
	end
end

def exec_cmd(cmd2exec) 
	log "execute: #{cmd2exec}"
	%x[ #{cmd2exec} ]
end

def modify_ini_file(ini_file, lhost_agent_name, lhost_agent_collector)
    
#	fileArray = []
#	open(ini_file).each { |x| 
#		line = x.gsub("\n",'')
#		if line == 'Name host' 
#			line = 'Name ' + lhost_agent_name
#		elsif line == 'Server localhost' 
#			line = 'Server ' + lhost_agent_collector
#		end
#		line = line + "\n"
#		fileArray << line
#	}
#
#	open(ini_file, "w") do |f| 
#		#fileArray.each { |element| f.puts(element) }
#		f.puts(fileArray)
#	end

  Dynatrace::Helpers.file_append_or_replace_line(ini_file, "Name host", 'Name ' + lhost_agent_name)
  Dynatrace::Helpers.file_append_or_replace_line(ini_file, "Server localhost", 'Server ' + lhost_agent_collector)
#  open(ini_file).each { |x| 
#    line = x.gsub("\n",'')
#    puts '#####: ' + line
#  }
  
end
