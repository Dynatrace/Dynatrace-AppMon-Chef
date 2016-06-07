#
# Cookbook Name:: dynatrace
# Recipes:: helpers
#
# Copyright 2016, Dynatrace
#

if platform_family?('debian', 'fedora', 'rhel')
  # Ensure the package is installed before using helper methods
  package 'rsync' do
    action :install
  end
else
  raise "Unsupported platform family."
end
