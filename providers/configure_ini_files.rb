#
# Cookbook Name:: dynatrace
# Providers:: configure_ini_files
#
# Copyright 2015, Dynatrace
#

action :run do
  update_status = false
  use_inline_resources
  new_resource.ini_files.each do |ini_file|
    next if new_resource.variables[:memory].nil?
    ini_file_path = "#{new_resource.installer_prefix_dir}/dynatrace/#{ini_file}"
    updated = Dynatrace::FileHelpers.file_cond_append_or_replace(ini_file_path, "-memory\n.*?\n", "-memory\n#{new_resource.variables[:memory]}\n")
    update_status = true if updated
  end
end
