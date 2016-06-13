#
# Cookbook Name:: dynatrace
# Providers:: delete_directory_by_link
#
# Copyright 2016, Dynatrace
#

action :run do
  ruby_block "Remove a directory using symbolic link: #{new_resource.link2delete}" do
    block do
      #remove directory using symlink
      cmd2exec = "rm -rf \"$(readlink #{new_resource.link2delete})\""
      execute "Remove directory content using symlink: #{cmd2exec}" do
        command cmd2exec
      end
      
      #remove symlink
      cmd2exec = "rm -rf #{new_resource.link2delete}"
      execute "Remove symlink: #{cmd2exec}" do
        command cmd2exec
      end
      
      # this should delete directory and symlink but removes only symlink
      directory "Delete the installation directory #{new_resource.link2delete}" do
        path      new_resource.link2delete
        recursive true
        action    :delete
      end
      
    end
  end
end
