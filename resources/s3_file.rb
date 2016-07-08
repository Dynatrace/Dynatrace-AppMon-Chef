#
# Cookbook Name:: dynatrace
# Resource:: s3_file
#
# Author:: Piotr Ozieblo
# Copyright:: Copyright 2016, Dynatrace
#
require 'fileutils'
require 'aws-sdk'

actions :create
default_action :create

property :object_name, String, name_property: true
property :local_path, String
property :bucket, String
property :region, String
property :access_key_id, String
property :secret_access_key, String

action :download do

  # ruby_block "Downloading S3 object '#{object_name}'" do
  #   block do
      s3 = Dynatrace::S3Helpers.init_s3_client(region, access_key_id, secret_access_key)

      Chef::Log.debug "Retrieving metadata for s3://#{bucket}/#{object_name} object"
      object_exists = true
      begin
        header_resp = s3.head_object({ bucket: bucket, key: object_name })
      rescue
        object_exists = false
      end
      Chef::Log.debug "Metadata retrieved"

      updated = false
      s3cache = Dynatrace::CacheData.new('s3cache')
      FileUtils::mkdir_p ::File.dirname(local_path)
      if !object_exists or !s3cache.valid?(local_path, header_resp.etag)
        puts "Downloading s3://#{bucket}/#{object_name} object" #TODO!
        Chef::Log.info "Downloading s3://#{bucket}/#{object_name} object"
        resp = s3.get_object({ bucket: bucket, key: object_name }, target: local_path)
        s3cache.save(local_path, resp.etag)
        puts "Downloading s3://#{bucket}/#{object_name} completed" #TODO!
        Chef::Log.debug "Downloading s3://#{bucket}/#{object_name} completed"
        updated = false
      else
        puts "No need to download s3://#{bucket}/#{object_name} - existing file is valid" #TODO!
        Chef::Log.info "No need to download s3://#{bucket}/#{object_name} - existing file is valid"
      end

      new_resource.updated_by_last_action(updated)
#    end
#end
end

action :upload do

  # ruby_block "Uploading S3 object '#{object_name}'" do
  #   block do

      s3 = Dynatrace::S3Helpers.init_s3_client(region, access_key_id, secret_access_key)

      puts "Retrieving metadata for s3://#{bucket}/#{object_name} object" #TODO!

      Chef::Log.debug "Retrieving metadata for s3://#{bucket}/#{object_name} object"
      object_exists = true
      begin
        header_resp = s3.head_object({ bucket:bucket, key:object_name })
      rescue
        object_exists = false
      end
      Chef::Log.debug "Metadata retrieved"

      updated = false
      s3cache = Dynatrace::CacheData.new('s3cache')
      if !object_exists or !s3cache.valid?(local_path, header_resp.etag)
        puts "Uploading s3://#{bucket}/#{object_name} object" #TODO!
        Chef::Log.info "Uploading s3://#{bucket}/#{object_name} object"
        resp = s3.put_object(bucket: bucket, key: object_name, body: local_path)
        puts "Uploading s3://#{bucket}/#{object_name} object, resp: #{resp}" #TODO!
        s3cache.save(local_path, resp.etag)
        Chef::Log.debug "Uploading s3://#{bucket}/#{object_name} completed"
        updated = true
      else
        puts "No need to upload s3://#{bucket}/#{object_name} - existing file is valid" #TODO!
        Chef::Log.info "No need to upload s3://#{bucket}/#{object_name} - existing file is valid"
      end
  #   end
  # end
  new_resource.updated_by_last_action(updated)
end
