#
# Cookbook Name:: dynatrace
# Providers:: run_tar_installer
#
# Copyright 2015, Dynatrace
#

action :run do
  execute "Extract the #{new_resource.name} tarball" do
    command "tar xvf #{new_resource.installer_path}"
    cwd     ::File.dirname(new_resource.installer_path)
  end

  execute "Install the #{new_resource.name}" do
    command 'sh dynatrace-*.sh'
    cwd     ::File.dirname(new_resource.installer_path)
  end

  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
      installation_path_part = Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :tar)
      installation_path = "#{new_resource.installer_prefix_dir}/#{installation_path_part}"

      res = resources("execute[Move the installation directory to #{new_resource.installer_prefix_dir}]")
      res.command get_mv_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{installation_path_part}", new_resource.installer_prefix_dir)

      res = resources('execute[Change ownership of the installation directory]')
      res.command get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)

      res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/dynatrace]")
      res.to installation_path
    end
  end

  execute "Move the installation directory to #{new_resource.installer_prefix_dir}" do
    command nil
  end

  execute 'Change ownership of the installation directory' do
    command nil
  end

  link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/dynatrace" do
    target_file "#{new_resource.installer_prefix_dir}/dynatrace"
    to nil
  end

  execute "Remove the #{new_resource.name} installer" do
    command 'rm -f dynatrace-*.sh'
    cwd     new_resource.installer_prefix_dir
  end

  file "Remove the #{new_resource.name} tarball" do
    path 'new_resource.installer_path'
    action :delete
  end
end

def get_chown_recursively_cmd(dir, owner, group)
  "chown -R #{owner}:#{group} #{dir}"
end

def get_mv_install_dir_cmd(src, dest)
  "mv #{src} #{dest}"
end
