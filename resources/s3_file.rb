#
# Cookbook Name:: dynatrace
# Resource:: s3_file
#
# Author:: Piotr Ozieblo
# Copyright:: Copyright 2016, Dynatrace
#
require 'fileutils'
require 'scanf'

actions :create
default_action :create

property :target, String, name_property: true
property :source, String
property :region, String
property :access_key_id, String
property :secret_access_key, String
property :owner, String
property :group, String
property :mode, String

action :create do
  require 'aws-sdk'

  # Detecting if we want to upload or download from S3
  upload_to_s3 = false
  if source.start_with?('s3://')
    s3_url = source.dup
  elsif target.start_with?('s3://')
    s3_url = target.dup
    upload_to_s3 = true
  else
    raise "Neither source nor target is an S3 URL"
  end

  # Extracting bucket and path to object from the provided URL
  # Example of S3 URL: s3://bucket_name/path/to/filename
  s3_url.slice!('s3://')
  s3_path_elems = s3_url.split('/', 2)
  bucket = s3_path_elems[0]
  object_name = s3_path_elems[1]

  s3 = Dynatrace::S3Helpers.init_s3_client(region, access_key_id, secret_access_key)

  Chef::Log.debug "Retrieving metadata for s3://#{bucket}/#{object_name} object"
  object_exists = false
  begin
    header_resp = s3.head_object({ bucket: bucket, key: object_name })
    object_exists = true
  rescue
    # Do nothing
  end
  Chef::Log.debug "Metadata retrieved"

  updated = false
  s3cache = Dynatrace::CacheData.new('s3cache')
  if upload_to_s3
    # Upload only if needed
    if !object_exists or !s3cache.valid?(source, header_resp.etag)
      Chef::Log.info "Uploading s3://#{bucket}/#{object_name} object"
      resp = nil
      ::File.open(source, 'rb') do |file|
        resp = s3.put_object(bucket: bucket, key: object_name, body: file)
      end
      s3cache.save(source, resp.etag)
      Chef::Log.debug "Uploading s3://#{bucket}/#{object_name} completed"
      updated = true
    end
  else
    if !object_exists
      raise "Could not retrieve #{source}"
    end
    # Download only if needed
    if !s3cache.valid?(target, header_resp.etag)
      Chef::Log.info "Downloading s3://#{bucket}/#{object_name} object"
      resp = s3.get_object({ bucket: bucket, key: object_name }, target: target)
      s3cache.save(target, resp.etag)
      Chef::Log.debug "Downloading s3://#{bucket}/#{object_name} completed"
      FileUtils.chown owner, group, target if !owner.nil? || !group.nil?
      # Accept strings in mode parameter as in other Chef resources. FileUtils.chmod accepts only integers.
      # e.g. "0644" => 420, "644" => 420 (= 0644)
      mode = mode.scanf("%o")[0] if mode.kind_of? String
      FileUtils.chmod mode, target if !mode.nil?
      updated = true
    end
  end

  if !updated
    Chef::Log.info "#{target} up to date"
  end

  # Setting the right status is important when using the Chef notification mechanism
  new_resource.updated_by_last_action(updated)
end

