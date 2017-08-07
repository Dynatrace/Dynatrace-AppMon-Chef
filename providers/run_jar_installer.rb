#
# Cookbook Name:: dynatrace
# Providers:: run_jar_installer
#
# Copyright 2016, Dynatrace
#

action :run do
  use_inline_resources
  jar_cmd = !new_resource.jar_input_sequence.nil? ? "echo -e '#{new_resource.jar_input_sequence}'" : 'yes'
  jar_cmd << " | java -jar #{new_resource.installer_path}"

  bash "Install the #{new_resource.name}" do
    code jar_cmd.to_s
    cwd  ::File.dirname(new_resource.installer_path)
  end

  if new_resource.target_dir.nil?
    new_resource.target_dir = Dynatrace::PackageHelpers.get_install_dir_from_installer(new_resource.installer_path, :jar)
  end

  ruby_block "Determine the #{new_resource.name}'s installation directory" do
    block do
      installation_path = "#{new_resource.installer_prefix_dir}/#{new_resource.target_dir}"

      res = resources("execute[Move the installation directory to #{new_resource.installer_prefix_dir}]")
      res.command get_mv_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{new_resource.target_dir}", new_resource.installer_prefix_dir)

      res = resources('execute[Change ownership of the installation directory]')
      res.command get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)

      res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}]")
      res.to installation_path
    end
  end

  execute "Move the installation directory to #{new_resource.installer_prefix_dir}" do
    command nil
  end

  execute 'Change ownership of the installation directory' do
    command nil
  end

  link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}" do
    target_file "#{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}"
    owner new_resource.dynatrace_owner
    group new_resource.dynatrace_group
    to nil
  end
end

def get_chown_recursively_cmd(dir, owner, group)
  "chown -R #{owner}:#{group} #{dir}"
end

def get_mv_install_dir_cmd(src, dest)
  # puts 'mv_install_dir_cmd src:' + src + ' dest:' +dest
  "rsync -a #{src} #{dest} && rm -rf #{src}"
end
