

# installer_file_name  = node['dynatrace']['server']['linux']['installer']['file_name']
# installer_file_url   = node['dynatrace']['server']['linux']['installer']['file_url']
# installer_cache_dir = "#{Chef::Config['file_cache_path']}/dynatrace"
# installer_path      = "#{installer_cache_dir}/#{installer_file_name}"

log "test_s3_file"

# puts "installer_file_name #{installer_file_name}
# installer_file_url
# installer_path
# attribute :s3_bucket,            #{node['dynatrace']['s3']['bucket']}
# attribute :s3_access_key_id,     #{node['dynatrace']['s3']['access_key_id']}
# attribute :s3_secret_access_key, #{node['dynatrace']['s3']['secret_access_key']}
#      "
#
# dynatrace_copy_or_download_file "#{name}" do
#   file_name       installer_file_name
#   file_url        installer_file_url
#   path            installer_path
# end
