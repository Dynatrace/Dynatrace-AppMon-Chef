#
# Cookbook Name:: dynatrace
# Providers:: delete_directory_by_link
#
# Copyright 2016, Dynatrace
#

# Let the notifications from nested resources be seen outside this LWRP
use_inline_resources

action :run do
  ruby_block "Remove a directory using symbolic link: #{new_resource.link2delete}" do
    block do
      # remove directory using symlink (Chef directory resource does not work in this case)
      cmd2exec = "rm -rf \"$(readlink #{new_resource.link2delete})\""
      execute "Remove directory content using symlink: #{cmd2exec}" do
        command cmd2exec
        only_if { ::File.exist?(new_resource.link2delete) }
      end

      link new_resource.link2delete do
        action :delete
      end
    end
  end
end
