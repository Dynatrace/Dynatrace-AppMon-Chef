#
# Cookbook Name:: dynatrace
# Providers:: run_jar_installer
#
# Copyright 2016, Dynatrace
#

action :run do
  jar_cmd = !new_resource.jar_input_sequence.nil? ? "echo -e '#{new_resource.jar_input_sequence}'" : 'yes'
  jar_cmd << " | java -jar #{new_resource.installer_path}"

  bash "Install the #{new_resource.name}" do
    code "#{jar_cmd}"
    cwd  ::File.dirname(new_resource.installer_path)
  end
	  
  if new_resource.name == "Easy Travel"
	# for EasyTravel
	installation_path_part = "easytravel-2.0.0"
	installation_last_path_part = "easytravel"
  else
	# for Dynatrace
	installation_path_part = Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :jar)
	installation_last_path_part = "dynatrace"
  end
  
  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
	  installation_path = "#{new_resource.installer_prefix_dir}/#{installation_path_part}"

      res = resources("execute[Move the installation directory to #{new_resource.installer_prefix_dir}]")
      res.command get_mv_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{installation_path_part}", new_resource.installer_prefix_dir)

      res = resources("execute[Change ownership of the installation directory]")
      res.command get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)

      res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{installation_last_path_part}]")
      res.to installation_path
    end
  end

  execute "Move the installation directory to #{new_resource.installer_prefix_dir}" do
    command nil
  end

  execute "Change ownership of the installation directory" do
    command nil
  end

  link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{installation_last_path_part}" do
    target_file "#{new_resource.installer_prefix_dir}/#{installation_last_path_part}"
    to nil
  end

  
  if new_resource.name == "Easy Travel"
	  ruby_block "Start installed program #{new_resource.name}" do
		block do
		  cmd_to_start = "#{new_resource.installer_prefix_dir}/#{installation_last_path_part}/weblauncher/weblauncher.sh&"
		  execute "#{cmd_to_start}" do
			command cmd_to_start
		  end
		end
	  end
  end
end

def get_chown_recursively_cmd(dir, owner, group)
  return "chown -R #{owner}:#{group} #{dir}"
end

def get_mv_install_dir_cmd(src, dest)
  return "mv #{src} #{dest}"
end

def get_rm_install_dir_cmd(dir)
  return "rm -r -f #{dir}"
end

def get_start_cmd(dest)
  return "#{dest}"
end
