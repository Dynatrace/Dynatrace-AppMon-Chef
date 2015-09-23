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
      dynatrace_file_append_line "Add the #{new_resource.name}'s -memory setting into '#{new_resource.installer_prefix_dir}/dynatrace/#{ini_file}'" do
        path "#{new_resource.installer_prefix_dir}/dynatrace/#{ini_file}"
        line "-memory\n#{new_resource.variables[:memory]}"
      end
    end
  end
end
