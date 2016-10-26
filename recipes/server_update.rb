# Cookbook Name:: dynatrace
# Recipes:: server_update
#
# Copyright 2016, Dynatrace
#

require 'net/https'
require 'rexml/document'

unless platform_family?('debian', 'fedora', 'rhel')
  raise 'Unsupported platform family.'
end

update_file_url = node['dynatrace']['server']['linux']['update']['update_file_url']
if update_file_url.to_s.empty?
  raise "attribute node['dynatrace']['server']['linux']['update']['update_file_url'] has to be specified"
end

cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
directory 'Create the installer cache directory' do
  path   cache_dir
  action :create
end

update_file_url = node['dynatrace']['server']['linux']['update']['update_file_url']
update_file_zip_path = "#{cache_dir}/server_update.zip"
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
        next unless File.extname(f.name) == '.dtf'
        # Extract with force overwriting existing file option set
        zip_file.extract(f, update_file_path) { true }
        dtf_file_unpacked = true
      end
    end
    unless dtf_file_unpacked
      raise "Could not extract dtf file from #{update_file_zip_path}"
    end
  end
end

chef_gem 'multipart-post' do
  compile_time false
end

# A REST URL to update Dynatrace server
rest_update_url = node['dynatrace']['server']['linux']['update']['rest_update_url']
user = node['dynatrace']['server']['linux']['update']['user']
passwd = node['dynatrace']['server']['linux']['update']['passwd']

ruby_block "Update Dynatrace server using #{update_file_path} file" do
  block do
    require 'net/http/post/multipart'
    uri = URI(rest_update_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    File.open(update_file_path) do |update_file|
      request = Net::HTTP::Post::Multipart.new uri, 'file' => UploadIO.new(update_file, 'application/octet-stream')
      request.basic_auth(user, passwd)
      response = http.request(request)

      raise "Server responded with error '#{response.code} #{response.message}' when trying to upload file #{update_file_path} through REST" unless response.code.to_s == '201'
      jobid = response['location'].split(%r{/})[-1]
      node.set['dynatrace']['server']['linux']['update']['jobid'] = jobid
    end
  end
end

ruby_block 'Waiting for update installation to finish' do
  block do
    begin
      jobid = node['dynatrace']['server']['linux']['update']['jobid']
      rest_update_status_url = "#{node['dynatrace']['server']['linux']['update']['rest_update_url']}/#{jobid}"
      timeout = node['dynatrace']['server']['linux']['update']['update_status_timeout']
      retry_sleep = node['dynatrace']['server']['linux']['update']['update_status_retry_sleep']
      Timeout.timeout(timeout) do
        loop do
          uri = URI(rest_update_status_url)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE

          request = Net::HTTP::Get.new(uri, 'Accept' => 'application/xml')
          request.basic_auth(user, passwd)
          response = http.request(request)

          raise "Server responded with error '#{response.code} #{response.message}' when trying to check update status" unless response.code == '200'
          xmldoc = REXML::Document.new(response.body)
          isfinished = REXML::XPath.first(xmldoc, '//isfinished').first == 'true'
          if isfinished
            isrestartrequired = REXML::XPath.first(xmldoc, '//isserverrestartrequired').first == 'true'
            node.set['dynatrace']['server']['linux']['update']['isrestartrequired'] = isrestartrequired
            break
          else
            Chef::Log.debug "Update not finished. Checking status in #{retry_sleep} seconds..."
            sleep retry_sleep
          end
        end
      end
    rescue Timeout::Error
      raise "Server not updated after #{timeout} seconds"
    end
  end
end

service_name = 'dynaTraceServer'
service service_name do
  # For Debian and Ubuntu distros - to correctly stop our service we need the status support which is disabled by default
  supports :status => true
  action [:restart]
  only_if { node['dynatrace']['server']['linux']['update']['isrestartrequired'] }
end

max_boot_time = node['dynatrace']['server']['max_boot_time']
rest_version_url = node['dynatrace']['server']['linux']['update']['rest_version_url']
ruby_block "Waiting for endpoint #{rest_version_url}" do
  block do
    Dynatrace::EndpointHelpers.wait_until_rest_endpoint_is_ready!(rest_version_url, max_boot_time)
  end
end
