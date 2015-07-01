#
# Cookbook Name:: dynatrace
# Providers:: run_tar_installer
#
# Copyright 2015, Dynatrace
#

action :run do
  execute "Extract the #{new_resource.name} tarball" do
    command "tar xvf #{new_resource.installer_path}"
    cwd     new_resource.installer_prefix_dir
  end

  execute "Install the #{new_resource.name}" do
    command "sh dynatrace-*.sh"
    cwd     new_resource.installer_prefix_dir
  end

  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
      installer_install_path = "#{new_resource.installer_prefix_dir}/" << Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :tar)

      res = resources("execute[Change ownership of the installation directory]")
      res.command get_chown_recursively_cmd(installer_install_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)
      
      res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/dynatrace]")
      res.to installer_install_path
    end
  end

  execute "Change ownership of the installation directory" do
    command nil
  end

  link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/dynatrace" do
    target_file "#{new_resource.installer_prefix_dir}/dynatrace"
    to nil
  end

  execute "Remove the #{new_resource.name} installer" do
    command "rm -f dynatrace-*.sh"
    cwd     new_resource.installer_prefix_dir
  end

  file "Remove the #{new_resource.name} tarball" do
    path "new_resource.installer_path"
    action :delete
  end
end

def get_chown_recursively_cmd(dir, owner, group)
  return "chown -R #{owner}:#{group} #{dir}"
end
