#
# Cookbook Name:: dynatrace
# Libraries:: cache_data
#
# Copyright 2016, Dynatrace
#
# All rights reserved - Do Not Redistribute
#

require 'fileutils'

module Dynatrace
  # Implements per-object storage of cache control data for S3 objects resources
  class CacheData
    def initialize(cache_id)
      @cache_id = cache_id
    end

    def valid?(target_path, etag)
      if File.file?(target_path) && cache_data_exists?(target_path)
        cache_data = load_cache_data(target_path)
        mtime = nil
        File.open(target_path) { |f| mtime = f.mtime }
        if (!etag.to_s.empty? && cache_data['etag'] == etag) \
            && cache_data['local_mtime'] == mtime
          return true
        end
      end
      false
    end

    def save(target_path, etag)
      metadata = { 'etag' => etag }
      # puts "Saving cache data to #{construct_filepath(target_path)}"
      File.open(target_path) { |f| metadata['local_mtime'] = f.mtime }
      File.open(construct_filepath(target_path), 'wb') { |f| f.write(Marshal.dump(metadata)) }
    end

    private

    def cache_data_exists?(target_path)
      File.file?(construct_filepath(target_path))
    end

    def load_cache_data(target_path)
      # puts "Opening cache data from #{construct_filepath(target_path)}"
      File.open(construct_filepath(target_path), 'rb') { |file| Marshal.load(file.read) }
    end

    def construct_filepath(target_path)
      "#{target_path}.#{@cache_id}"
    end
  end
end
