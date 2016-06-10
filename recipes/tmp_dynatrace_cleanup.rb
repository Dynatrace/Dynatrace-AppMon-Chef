directory "Delete the installation directory /opt/dynatrace-6.3" do
  path      "/opt/dynatrace-6.3"
  recursive true
  action    :delete
end

execute 'rm /opt/dynatrace; true'

#TODO!
execute 'rm /etc/init.d/dynaTrace*; ps U dynatrace > dynauserproc.txt; true;'

execute 'rm -rf /var/chef/cache/dynatrace; true;'


user "Delete user 'dynatrace'" do

  username 'dynatrace'
  supports :manage_home=>true
  action   :remove
end

group "Delete group 'dynatrace'" do
  group_name 'dynatrace'
  action     :remove
end