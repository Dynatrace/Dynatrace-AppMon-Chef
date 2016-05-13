#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::wsagent_package'

name = "Dynatrace Apache WebServer Agent"

apache_config_file_path     = node['dynatrace']['apache_wsagent']['apache']['config_file_path']
apache_init_script_path     = node['dynatrace']['apache_wsagent']['apache']['init_script_path']
apache_do_patch_init_script = node['dynatrace']['apache_wsagent']['apache']['do_patch_init_script']

if platform_family?('debian', 'fedora', 'rhel')
  agent_path = node['dynatrace']['apache_wsagent']['linux']['agent_path']
else
  # Unsupported
end

ruby_block "Inject the #{name} into Apache HTTPD's config file" do
  block do
    Dynatrace::Helpers.file_append_line(apache_config_file_path, "LoadModule dtagent_module \"#{agent_path}\"")
  end
end
