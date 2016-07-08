#TODO! object_name/bucket na remote_path

# chef_gem 'aws-sdk' do
#   compile_time true
# end
#
# file 'C:/Users/piotr.ozieblo/Downloads/tmp/precedense_test.txt' do
#   action :touch
# end
#
# puts "kilka slow"



dynatrace_s3_file 'dynatrace/test.txt' do
  local_path 'C:/Users/piotr.ozieblo/Downloads/tmp/test.txt'
  bucket 'downloads.dynasprint'
  region 'us-east-1'
  access_key_id 'AKIAIL5TX6WS22JYI34Q'
  secret_access_key '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'
  action :upload
  notifies :run, "ruby_block[aaa]", :immediately
end

ruby_block "aaa" do
  block do
    puts "\nJestem tu!!!!!!!!!!!!"
  end
  action :nothing
end