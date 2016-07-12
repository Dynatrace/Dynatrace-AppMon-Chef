module Dynatrace
  module S3Helpers
    # NOTE: a "require 'aws-sdk'" should be placed before calling this method
    def self.init_s3_client(region, access_key_id, secret_access_key)
      credentials = Aws::Credentials.new(access_key_id, secret_access_key)
      shared_credentials = Aws::SharedCredentials.new
      if (access_key_id.nil? and secret_access_key.nil? and shared_credentials.loadable?)
        credentials = shared_credentials
      end
      s3 = Aws::S3::Client.new(region: region, credentials: credentials)
    end
  end
end