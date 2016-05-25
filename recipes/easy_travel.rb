#
# Cookbook Name:: easy_travel
# Recipes:: dynatrace
# will install Easy Travel
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'

include_recipe 'java'
include_recipe 'dynatrace::dynatrace_user'
include_recipe 'dynatrace::agents_package'
name = 'Easy Travel'

installer_bitsize = node['easy_travel']['installer']['bitsize']
dynatrace_owner = node['current_user']# node['dynatrace']['owner']
dynatrace_group = node['current_user']# node['dynatrace']['group']

# assume that we can install Easy Travel, it will be verified now
could_be_installed = true

if platform_family?('debian', 'fedora', 'rhel')
   # See http://stackoverflow.com/questions/8328250/centos-64-bit-bad-elf-interpreter
  package 'glibc.i686'

  installer_prefix_dir = node['easy_travel']['linux']['installer']['prefix_dir']
  installer_file_name  = node['easy_travel']['linux']['installer']['file_name']
  installer_file_url   = node['easy_travel']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/easy_travel"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
else
	# Unsupported platform
	could_be_installed = false
	log 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be installed.'
end

if could_be_installed == true then
	#creating tmp installer directory
	directory "Create the installer cache directory: #{installer_cache_dir}" do
	  path   installer_cache_dir
	  action :create
	end

	#download installation jar file
	dynatrace_copy_or_download_file "Downloading installation jar file: #{name}" do
	  file_name       installer_file_name
	  file_url        installer_file_url  
	  path            installer_path
	  dynatrace_owner dynatrace_owner
	  dynatrace_group dynatrace_group
	end

	ruby_block "#{name}" do
	  block do
		node.set[:easy_travel][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, '', type=:jar)
	  end
	end

	#creating installation directory
	directory "Create the installation directory #{installer_prefix_dir}" do
	  path      installer_prefix_dir
	  owner     dynatrace_owner unless ::File.exist?(installer_prefix_dir)
	  group     dynatrace_group unless ::File.exist?(installer_prefix_dir)
	  recursive true
	  action    :create
	  only_if { node[:easy_travel][:installation][:is_required] }
	end
  
  symlink = 'easytravel'
  version = node['easy_travel']['linux']['installer']['version']

	#perform installation of Easy Travel
	dynatrace_run_jar_installer "#{name}" do
	  installer_path       installer_path
	  installer_prefix_dir installer_prefix_dir
    target_dir           "easytravel-#{version}"
    target_symlink       symlink
	  jar_input_sequence   "#{installer_bitsize}\\nY\\nY\\nY"
	  dynatrace_owner      dynatrace_owner
	  dynatrace_group      dynatrace_group
	  only_if { node[:easy_travel][:installation][:is_required] }
	end
  
  config_path = "#{installer_prefix_dir}/#{symlink}/resources/easyTravelConfig.properties"
  config_path_training = "#{installer_prefix_dir}/#{symlink}/resources/easyTravelTrainingConfig.properties"
  
  #switch to training mode - we want to inject agents ourselves
  remote_file  'Switch to training mode' do
    path config_path
    source "file://#{config_path_training}"
  end
  
  # Inject Apache WebServer agent
  httpconf_tmp_path = "#{installer_prefix_dir}/#{symlink}/resources/custom_httpd.conf"
  template httpconf_tmp_path do
    source 'easy_travel/httpd.conf.erb'
    owner  dynatrace_owner
    group  dynatrace_owner
    mode   '0644'
    variables({
      :easy_travel_install_prefix => installer_prefix_dir,
      :version => version})
    action :create
  end
  
  node.set['dynatrace']['apache_wsagent']['arch'] = 'x86'
  node.set['dynatrace']['apache_wsagent']['apache']['config_file_path'] = httpconf_tmp_path
  include_recipe 'dynatrace::apache_wsagent'
  
  ruby_block "Inject Apache Web server agent into #{name}" do
    block do 
      agent_path = node['dynatrace']['apache_wsagent']['agent_path']
      # Setting agent path here is needed only to display the correct status by web console
      Dynatrace::Helpers.file_append_or_replace_line(config_path, "config.apacheWebServerAgent=", "config.apacheWebServerAgent=#{agent_path}")
      Dynatrace::Helpers.file_append_or_replace_line(config_path, "config.apacheWebServerUsesGeneratedHttpdConfig=", "config.apacheWebServerUsesGeneratedHttpdConfig=false")
      Dynatrace::Helpers.file_append_or_replace_line(config_path, "config.apacheWebServerHttpdConfig=", "config.apacheWebServerHttpdConfig=#{httpconf_tmp_path}")
    end
  end
  
  # Inject Java agents
  agent_path = node['dynatrace']['java_agent']['linux']['x86']['agent_path']
  
  dynatrace_java_agent 'backendJavaAgent' do
    agent_path agent_path
  end

  dynatrace_java_agent 'frontendJavaAgent' do
    agent_path agent_path
  end

  ruby_block "Inject Java agents into #{name}" do
    block do 
      backendOptsKey = 'config\.backendJavaopts='
      frontendOptsKey = 'config\.frontendJavaopts='
      defaultOptsBackend = ''
      defaultOptsFrontend = ''
      # Read the default javaopts from the template config file
      File.new(config_path_training).each_line do |line|
        if defaultOptsBackend.empty?
          m = /#{backendOptsKey}\S*/.match(line)
          defaultOptsBackend = m[0] if m
        end
        if defaultOptsFrontend.empty?
          m = /#{frontendOptsKey}\S*/.match(line)
          defaultOptsFrontend = m[0] if m
        end
        if !defaultOptsBackend.empty? && !defaultOptsFrontend.empty?
          break
        end
      end
      # Comma character requires escaping
      backendAgentOpts = node['dynatrace']['java_agent']['javaopts']['backendJavaAgent'].gsub(/,/, ",,")
      frontendAgentOpts = node['dynatrace']['java_agent']['javaopts']['frontendJavaAgent'].gsub(/,/, ",,")
      # Append Java agent related options to javaopts
      backendJavaOpts = "#{defaultOptsBackend},#{backendAgentOpts}"
      frontendJavaOpts = "#{defaultOptsFrontend},#{frontendAgentOpts}"
      Dynatrace::Helpers.file_replace_line(config_path, backendOptsKey, "#{backendJavaOpts}")
      Dynatrace::Helpers.file_replace_line(config_path, frontendOptsKey, "#{frontendJavaOpts}")
    end
  end
  
  ruby_block "Stop any running instance of #{name}" do
    block do
      Dynatrace::Helpers.stop_processes(node['easy_travel']['proc_pattern'], node['platform_family'])
    end
  end
  
  execute "Start installed program #{name}" do
    command "#{installer_prefix_dir}/#{symlink}/weblauncher/weblauncher.sh&"
  end

end
