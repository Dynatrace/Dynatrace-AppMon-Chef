#
# Configure demo Dynatrace setup with easyTravel
#
# Cookbook Name:: dynatrace_demo
# Recipe:: default
#
# Copyright 2016, Dynatrace
#
# All rights reserved - Do Not Redistribute
#

require 'chef/provisioning/ssh_driver'
with_driver 'ssh'

dynaserver_node_addr = node['dynatrace']['dynaserver_node_addr']
collector_node_addr = node['dynatrace']['collector_node_addr']
easytravel_node_addr = node['dynatrace']['easytravel_node_addr']
host_agent_name = node['dynatrace']['host_agent_name']
license_url = node['dynatrace']['server_license_url']
chef_cert_local_path = node['dynatrace']['chef_certificate_local_path']
cher_cert_name = node['dynatrace']['chef_certificate_name']

def connection_opts(addr)
  {:transport_options => {
    :host => addr,
    :username => node['dynatrace']['login_user'],
    :ssh_options => {
    # This seems to be a bug in ssh_driver, we have to explicitely give 
    # the private key location even for standard location
      :keys => ['~/.ssh/id_rsa'],
    }
  }}
end


#
# 1. uninstall the Collector; parameters defined in collector_node_addr = node['dynatrace']['collector_node_addr']
#
collector_node_opts = connection_opts(collector_node_addr)
machine 'collector' do
  file "/etc/chef/trusted_certs/#{cher_cert_name}", "#{chef_cert_local_path}/#{cher_cert_name}"
  machine_options collector_node_opts
  attribute %w[dynatrace collector server hostname], dynaserver_node_addr
  chef_environment node.chef_environment
  run_list ['dynatrace::collector_uninstall']
end

#
# 2. uninstall the Host Agent and Easy Travel; parameters defined in easytravel_node_addr = node['dynatrace']['easytravel_node_addr']
#
easytravel_node_opts = connection_opts(easytravel_node_addr)
machine 'easytravel' do
  file "/etc/chef/trusted_certs/#{cher_cert_name}", "#{chef_cert_local_path}/#{cher_cert_name}"
  machine_options easytravel_node_opts
  #chef_environment node.chef_environment
  attribute %w[dynatrace wsagent_package collector_hostname], collector_node_addr
  attribute %w[dynatrace java_agent collector hostname], collector_node_addr
  attribute %w[dynatrace host_agent collector], collector_node_addr
  attribute %w[dynatrace host_agent host_agent_name], host_agent_name
  run_list ['dynatrace::host_agent_uninstall', 'dynatrace::easy_travel_uninstall'] 
end

#
# 3. uninstall the Host Agent on machine where collector was installed as separate recipe; parameters defined in collector_node_addr = node['dynatrace']['collector_node_addr']
#
ha_collector_node_opts = connection_opts(collector_node_addr)
machine 'collector' do
  file "/etc/chef/trusted_certs/#{cher_cert_name}", "#{chef_cert_local_path}/#{cher_cert_name}"
  machine_options ha_collector_node_opts
  #chef_environment node.chef_environment
  attribute %w[dynatrace wsagent_package collector_hostname], collector_node_addr
  attribute %w[dynatrace java_agent collector hostname], collector_node_addr
  attribute %w[dynatrace host_agent collector], collector_node_addr
  attribute %w[dynatrace host_agent host_agent_name], host_agent_name
  run_list ['dynatrace::host_agent_uninstall'] 
end

#
# 4. uninstall the Host Agent and dynatrace server; parameters defined in dynaserver_node_addr = node['dynatrace']['dynaserver_node_addr']
#
ha_dynaserver_node_addr = connection_opts(dynaserver_node_addr)
machine 'server' do
  file "/etc/chef/trusted_certs/#{cher_cert_name}", "#{chef_cert_local_path}/#{cher_cert_name}"
  machine_options ha_dynaserver_node_addr
  #chef_environment node.chef_environment
  attribute %w[dynatrace wsagent_package collector_hostname], collector_node_addr
  attribute %w[dynatrace java_agent collector hostname], collector_node_addr
  attribute %w[dynatrace host_agent collector], collector_node_addr
  attribute %w[dynatrace host_agent host_agent_name], host_agent_name
  run_list ['dynatrace::host_agent_uninstall', 'dynatrace::server_uninstall'] 
end

#sudo killall -9 -u dynatrace
#sudo killall -9 -u easytravel
#
#debian:  sudo deluser --remove-home easytravel
#redhat:  sudo userdel --remove dynatrace
#
#sudo groupdel dynatrace

