#
# Cookbook Name:: dynatrace
# Recipes:: node_info
#
# Copyright 2016, Dynatrace
#

# for EC2 instance it can be:
node_platform = node['platform']                  # "amazon"
node_platform_version = node['platform_version']  # "2016.03"
node_os = node['os']                              # "linux"
node_os_version = node['os_version']              # "4.4.5-15.26.amzn1.x86_64"
node_kernel_machine = node['kernel']['machine']   # "x86_64"
node_ipaddress = node['ipaddress']

ec2 = node['ec2']
if !ec2.nil?
  node_public_hostname = node['ec2']['public_hostname']
  node_public_ipv4 = node['ec2']['public_ipv4']
  node_local_ipv4 = node['ec2']['local_ipv4']
else
  node_public_hostname = nil
  node_public_ipv4 = nil
  node_local_ipv4 = nil
end

Chef::Log.info '########################################## cookbook: ' + cookbook_name + ' ################################'

unless node_public_hostname.nil?
  Chef::Log.info 'Node public host name:' + node_public_hostname
end
unless node_public_ipv4.nil?
  Chef::Log.info 'Node public IP Address:' + node_public_ipv4
end
if !node_local_ipv4.nil?
  Chef::Log.info 'Node local IP Address:' + node_local_ipv4
elsif !node_ipaddress.nil?
  Chef::Log.info 'Node IP Address:' + node_ipaddress
end

if !node_ipaddress.nil? && !node_local_ipv4.nil?
  if node_local_ipv4 != node_ipaddress
    Chef::Log.info 'Node IP Address:' + node_ipaddress unless node_ipaddress.nil?
  end
end

if !node_platform.nil? && !node_platform_version.nil? && !node_os.nil? && !node_os_version.nil? && !node_kernel_machine.nil?
  Chef::Log.info 'Platform:' + node_platform + '  version:' + node_platform_version + '  os:' + node_os.to_s + '  os_version:' + node_os_version.to_s + '  machine:' + node_kernel_machine.to_s
end
