#require 'aws-sdk'

module Dynatrace
  module S3Helpers
    def self.init_s3_client(region, access_key_id, secret_access_key)
      credentials = Aws::Credentials.new(access_key_id, secret_access_key)
      if (access_key_id.nil? and secret_access_key.nil? and Aws::SharedCredentials.loadable?)
        credentials = Aws::SharedCredentials.new
      end
      s3 = Aws::S3::Client.new(region: region, credentials: credentials)
    end
  end
end