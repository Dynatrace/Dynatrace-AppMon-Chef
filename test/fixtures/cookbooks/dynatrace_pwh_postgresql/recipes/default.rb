include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

connection_info = {
  :host => '127.0.0.1',
  :port => '5432',
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_version = node['postgresql']['version']

=begin
directory "/etc/postgresql/#{postgresql_version}/main/" do
  owner 'postgres'
  group 'postgres'
  mode '0755'
  action :create
end
=end

postgresql_database 'dynatrace-pwh' do
  connection connection_info
  action :create
end

postgresql_database_user 'dynatrace' do
  connection connection_info
  password 'dynatrace'
  superuser false
  action :create
end
