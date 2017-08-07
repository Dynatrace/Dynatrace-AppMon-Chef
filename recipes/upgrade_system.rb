#
# Cookbook Name:: upgrade_system
# Recipes:: dynatrace
# will update system
# Copyright 2016, dynatrace
#
include_recipe 'dynatrace-appmon::node_info'

upgrade_system = node['upgrade']['system']

if upgrade_system == 'yes'
  unless platform_family?('debian', 'fedora', 'rhel')
    raise 'Unsupported platform family.'
  end
  if platform_family?('fedora', 'rhel')
    execute 'Update system' do
      command 'yum update -y'
    end
  elsif platform_family?('debian')
    execute 'Update package index' do
      command 'apt-get update -y'
    end
    execute 'Update system' do
      command 'apt-get upgrade -y'
    end
  else
    log 'Unsupported platform family. System will not be upgraded.' do
      level :warn
    end
  end
else
  log 'System will not be upgraded - default settings has been overridden.' do
    level :info
  end
end
