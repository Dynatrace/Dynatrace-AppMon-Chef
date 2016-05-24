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
		modify_ini_file("#{install_dir}/#{installation_path_part}/agent/conf/dthostagent.ini")
		exec_cmd("cp #{install_dir}/#{installation_path_part}/init.d/dynaTraceHostagent /etc/init.d/")
		installation_path = "#{new_resource.installer_prefix_dir}/#{installation_path_part}"
		exec_cmd(mv_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{installation_path_part}", new_resource.installer_prefix_dir))
 		exec_cmd(get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group))
		link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/dynatrace" do
			target_file "#{new_resource.installer_prefix_dir}/dynatrace"
			to "#{installation_path}"
		end
	end
  end

#  execute "execute: chkconfig add dynaTraceHostagent" do
#    command "chkconfig --add /etc/init.d/dynaTraceHostagent"
#  end

  service 'dynaTraceHostagent' do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

  #manualy start service (I wasn't able start it different way)
  execute "start dynaTraceHostagent" do
    command "/etc/init.d/dynaTraceHostagent start"
  end
    
 
end

def get_chown_recursively_cmd(dir, owner, group)
  return "chown -R #{owner}:#{group} #{dir}"
end

def mv_install_dir_cmd(src, dest)
  return "mv #{src} #{dest}"
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

def modify_ini_file(ini_file)
	fileArray = []
	open(ini_file).each { |x| 
		line = x.gsub("\n",'')
		if line == 'Name host' 
			line = 'Name ' + new_resource.host_agent_name
		elsif line == 'Server localhost' 
			line = 'Server ' + new_resource.host_agent_collector
		end
		line = line + "\n"
		fileArray << line
	}

	open(ini_file, "w") do |f| 
		#fileArray.each { |element| f.puts(element) }
		f.puts(fileArray)
	end
end
