#
# Cookbook Name:: dynatrace
# Recipes:: apache_wsagent_uninstall
#
# Copyright 2016, Dynatrace
#

name = "Dynatrace Apache WebServer Agent uninstall"

apache_config_file_path = node['dynatrace']['apache_wsagent']['apache']['config_file_path']
apache_daemon = node['dynatrace']['apache_wsagent']['linux']['apache_daemon']

if platform_family?('debian', 'fedora', 'rhel')
  arch = node['dynatrace']['apache_wsagent']['arch']
  agent_path = node['dynatrace']['apache_wsagent']['linux'][arch]['agent_path']
  node.set['dynatrace']['apache_wsagent']['agent_path'] = agent_path
else
  log "Unsupported platform family." do
    level :warn
  end
end

ruby_block "Remove the #{name} from Apache HTTPD's config file #{apache_config_file_path}" do
  block do
    fileExists = apache_config_file_path
    if File.exist?(fileExists)
      # Host Agent is already installed
      search_pattern = "LoadModule dtagent_module"
      line_to_remove = "#{search_pattern} \"#{agent_path}\""
      
      puts "Search pattern: #{search_pattern}"
      puts "Line to remove: #{line_to_remove}"
      
      Dynatrace::Helpers.file_replace_line(fileExists, line_to_remove, '')
    end
  end
  if not apache_daemon.empty?
    notifies :restart, "service[#{apache_daemon}]", :immediately
  end
  ignore_failure true
end

apache_config_file_path = '/opt/easytravel/resources/custom_httpd.conf'
ruby_block "Remove the #{name} from Apache HTTPD's config file #{apache_config_file_path}" do
  block do
    fileExists = apache_config_file_path
    if File.exist?(fileExists)
      # Host Agent is already installed
      search_pattern = "LoadModule dtagent_module"
      line_to_remove = "#{search_pattern} \"#{agent_path}\""
      
      puts "Search pattern: #{search_pattern}"
      puts "Line to remove: #{line_to_remove}"
      
      Dynatrace::Helpers.file_replace_line(fileExists, line_to_remove, '')
    end
  end
  if not apache_daemon.empty?
    notifies :restart, "service[#{apache_daemon}]", :immediately
  end
  ignore_failure true
end

# We only state here that such a daemon already exists. We do this to
# make the notification mechanism work (see above). 
 if not apache_daemon.empty?
  service apache_daemon do
    action :nothing
  end
end

include_recipe 'dynatrace::wsagent_package_uninstall'
