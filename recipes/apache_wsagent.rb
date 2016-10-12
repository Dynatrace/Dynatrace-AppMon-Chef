#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent
#
# Copyright 2016, Dynatrace
#

include_recipe 'dynatrace::wsagent_package'

name = 'Dynatrace Apache WebServer Agent'

apache_config_file_path = node['dynatrace']['apache_wsagent']['apache']['config_file_path']
apache_daemon = node['dynatrace']['apache_wsagent']['linux']['apache_daemon']

raise 'Unsupported platform family.' unless platform_family?('debian', 'fedora', 'rhel')

arch = node['dynatrace']['apache_wsagent']['arch']
agent_path = node['dynatrace']['apache_wsagent']['linux'][arch]['agent_path']
node.set['dynatrace']['apache_wsagent']['agent_path'] = agent_path

ruby_block "Inject the #{name} into Apache HTTPD's config file #{apache_config_file_path}" do
  block do
    search_pattern = 'LoadModule dtagent_module'
    line_to_add = "#{search_pattern} \"#{agent_path}\""
    Dynatrace::Helpers.file_append_or_replace_line(apache_config_file_path, search_pattern, line_to_add)
  end
  notifies :restart, "service[#{apache_daemon}]" unless apache_daemon.empty?
end

# We only state here that such a daemon already exists. We do this to
# make the notification mechanism work (see above).
unless apache_daemon.empty?
  service apache_daemon do
    action :nothing
  end
end
