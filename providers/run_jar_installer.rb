#
# Cookbook Name:: dynatrace
# Providers:: run_jar_installer
#
# Copyright 2015, Dynatrace
#

action :run do
  jar_cmd = !new_resource.jar_input_sequence.nil? ? "echo -e '#{new_resource.jar_input_sequence}'" : 'yes'
  jar_cmd << " | java -jar #{new_resource.installer_path}"

  bash "Install the #{new_resource.name}" do
    code "#{jar_cmd}"
    cwd  new_resource.installer_prefix_dir
  end

  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
      installer_install_path = "#{new_resource.installer_prefix_dir}/" << Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :jar)

      res = resources("execute[Change ownership of the installation directory]")
      res.command get_chown_recursively_cmd(installer_install_path)

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

  file "Remove the #{new_resource.name} installer" do
    path new_resource.installer_path
    action :delete
  end
end

def get_chown_recursively_cmd(dir)
  return "chown -R dynatrace:dynatrace #{dir}"
end
