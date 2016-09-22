module Dynatrace
  module S3Helpers
    # NOTE: a "require 'aws-sdk'" should be placed before calling this method
    def self.init_s3_client(region, access_key_id, secret_access_key)
      if access_key_id.nil? && secret_access_key.nil?
        shared_credentials = Aws::SharedCredentials.new
        credentials = if shared_credentials.loadable?
                        shared_credentials
                      else
                        # Assume IAM role credentials
                        Aws::InstanceProfileCredentials.new
                      end
      else
        credentials = Aws::Credentials.new(access_key_id, secret_access_key)
      end
      s3 = Aws::S3::Client.new(:region => region, :credentials => credentials)
    end
  end
end
