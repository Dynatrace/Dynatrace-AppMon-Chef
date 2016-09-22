# Cookbook Name:: dynatrace
# Recipes:: server_update
#
# Copyright 2016, Dynatrace
#

require 'json'
require 'net/https'

if !platform_family?('debian', 'fedora', 'rhel')
  raise "Unsupported platform family."
end

update_file_url = node['dynatrace']['server']['linux']['update']['update_file_url']
if update_file_url.to_s.empty?
  raise "attribute node['dynatrace']['server']['linux']['update']['update_file_url'] has to be specified"
end

cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
directory "Create the installer cache directory" do
  path   cache_dir
  action :create
end

update_file_url = node['dynatrace']['server']['linux']['update']['update_file_url']
update_file_zip_path =  "#{cache_dir}/server_update.zip"
update_file_path = "#{cache_dir}/server_update.dtf"
dynatrace_copy_or_download_file "Downloading update file: #{update_file_url}" do
  file_url        update_file_url
  path            update_file_zip_path
  dynatrace_owner node['dynatrace']['owner']
  dynatrace_group node['dynatrace']['group']
end

chef_gem 'rubyzip' do
  compile_time false
end

ruby_block "Extract dtf file from #{update_file_zip_path} as #{update_file_path}" do
  block do
    require 'zip'
    dtf_file_unpacked = false
    Zip::File.open(update_file_zip_path) do |zip_file|
      zip_file.each do |f|
        if File.extname(f.name) == '.dtf'
          # Extract with force overwriting existing file option set
          zip_file.extract(f, update_file_path) { true }
          dtf_file_unpacked = true
        end
      end
    end
    if !dtf_file_unpacked
      raise "Could not extract dtf file from #{update_file_zip_path}"
    end
  end
end

package 'curl' do
  action :install
end

# A REST URL to update Dynatrace server
rest_update_url = node['dynatrace']['server']['linux']['update']['rest_update_url']
user = node['dynatrace']['server']['linux']['update']['user']
passwd = node['dynatrace']['server']['linux']['update']['passwd']

cmd2exec = "curl --insecure --header 'Content-Type:multipart/form-data' -F file='@#{update_file_path}' -u #{user}:#{passwd} -v '#{rest_update_url}'"
execute "Update Dynatrace server using #{update_file_path} file" do
  command cmd2exec
  live_stream true
end

service_name      = 'dynaTraceServer'
# Wait for server to prepare the udpate before restarting it
ruby_block "Wait before restarting service '#{service_name}'" do
  block do
    # TODO use the REST interface
    sleep 120
  end
end

service "#{service_name}" do
  action [:restart]
end

rest_version_url = node['dynatrace']['server']['linux']['update']['rest_version_url']
ruby_block "Waiting for endpoint #{rest_version_url}" do
  block do
    Dynatrace::Helpers.wait_until_rest_endpoint_is_ready!(rest_version_url)
  end
end
