#
# Cookbook Name:: dynatrace
# Providers:: configure_ini_files
#
# Copyright 2015, Dynatrace
#

use_inline_resources

action :run do
  new_resource.ini_files.each do |ini_file|
    if not new_resource.variables[:memory].nil?
      ruby_block "Add the #{new_resource.name}'s -memory setting into '#{new_resource.installer_prefix_dir}/dynatrace/#{ini_file}'" do
        block do
          Dynatrace::Helpers.file_append_or_replace_line("#{new_resource.installer_prefix_dir}/dynatrace/#{ini_file}", "-memory\n.*?\n", "-memory\n#{new_resource.variables[:memory]}")
        end
      end
    end
  end
end
