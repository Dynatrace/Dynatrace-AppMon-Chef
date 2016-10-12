#
# Cookbook Name:: dynatrace
# Providers:: run_tar_installer
#
# Copyright 2015, Dynatrace
#

action :run do
  install_base_dir_func = -> { ::File.dirname(new_resource.installer_path) }

  execute "Extract the tar installer #{new_resource.name}" do
    command "tar xf #{new_resource.installer_path} > /dev/null"
    cwd     install_base_dir_func.call
  end

  execute "Install the #{new_resource.name}" do
    command 'sh dynatrace-*.sh'
    cwd     ::File.dirname(new_resource.installer_path)
    only_if { !::Dir["#{install_base_dir_func.call}/dynatrace-*.sh"].empty? }
  end

  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
      installation_path_part = Dynatrace::PackageHelpers.get_install_dir_from_installer(new_resource.installer_path, :tar)
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
  "rsync -a #{src} #{dest} && rm -rf #{src}"
end
