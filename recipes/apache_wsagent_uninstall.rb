#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent_uninstall
#
# Copyright 2016, Dynatrace
#

name = 'Dynatrace Apache WebServer Agent uninstall'

apache_config_file_path = node['dynatrace']['apache_wsagent']['apache']['config_file_path']
apache_daemon = node['dynatrace']['apache_wsagent']['linux']['apache_daemon']

raise 'Unsupported platform family.' unless platform_family?('debian', 'fedora', 'rhel')

arch = node['dynatrace']['apache_wsagent']['arch']
agent_path = node['dynatrace']['apache_wsagent']['linux'][arch]['agent_path']
node.normal['dynatrace']['apache_wsagent']['agent_path'] = agent_path

ruby_block "Remove the #{name} from Apache HTTPD's config file #{apache_config_file_path}" do
  block do
    file_exists = apache_config_file_path
    if File.exist?(file_exists)
      # Host Agent is already installed
      search_pattern = 'LoadModule dtagent_module'
      line_to_remove = "#{search_pattern} \"#{agent_path}\""

      Dynatrace::FileHelpers.file_replace_line(file_exists, line_to_remove, '')
    end
  end
  unless apache_daemon.empty?
    notifies :restart, "service[#{apache_daemon}]", :immediately
  end
end

# We only state here that such a daemon already exists. We do this to
# make the notification mechanism work (see above).
unless apache_daemon.empty?
  service apache_daemon do
    action :nothing
  end
end

include_recipe 'dynatrace-appmon::wsagent_package_uninstall'
