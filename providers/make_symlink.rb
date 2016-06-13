#
# Cookbook Name:: dynatrace
# Providers:: make_symlink
#
# Copyright 2016, Dynatrace
#

action :run do
  
  ruby_block "Create a symbolic link" do
    block do
      if new_resource.target_dir.nil?
        new_resource.target_dir = Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :jar)
    
        link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}" do
          target_file "#{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}"
          to "#{new_resource.installer_prefix_dir}/#{new_resource.target_dir}"
        end
     
        exec_cmd(get_chown_link_cmd(new_resource.installer_prefix_dir + '/' + new_resource.target_symlink, new_resource.dynatrace_owner, new_resource.dynatrace_group))
      end
    end
  end
end

def get_chown_link_cmd(dir, owner, group)
  return "chown -h #{owner}:#{group} #{dir}"
end

def exec_cmd(cmd2exec) 
  puts "execute: #{cmd2exec}"
  %x[ #{cmd2exec} ]
end
