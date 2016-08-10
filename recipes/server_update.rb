# Cookbook Name:: dynatrace
# Recipes:: server_update
#
# Copyright 2015, Dynatrace
#

require 'json'
require 'net/https'

name = 'Dynatrace Server update'

#https://downloads.dynatracesaas.com/updates/dynaTrace-6.3.4.1034.zip

if platform_family?('debian', 'fedora', 'rhel')
  # update file name in the user home directory.
  update_file = node['dynatrace']['server']['linux']['update']['update_file']
  
  # A REST URL to update Dynatrace server
  rest_update_url = node['dynatrace']['server']['linux']['update']['rest_update_url']
    
  user = node['dynatrace']['server']['linux']['update']['user']
  passwd = node['dynatrace']['server']['linux']['update']['passwd']

  service      = 'dynaTraceServer'
else
  # Unsupported
end

fileExists = update_file
if File.exist?(update_file)
  # Dynatrace Server is already installed
  puts 'Dynatrace update file: ' + fileExists + ' exists. Update will be performed.'
  cmd2exec = "curl --insecure --header 'Content-Type:multipart/form-data' -F file='@#{update_file}' -u #{user}:#{passwd} -v '#{rest_update_url}'"
   
#  result = %x[ #{cmd2exec} ]     - no return information in result ...
  
  execute "Update Dynatrace server using #{update_file} file." do
    command cmd2exec
  end
    
else
  puts 'ERROR: Dynatrace update file: ' + fileExists + ' do not exists. Update will not be performed.'
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:stop]
end

service "#{name}" do
  service_name service
  supports     :status => true
  action       [:start, :enable]
end
