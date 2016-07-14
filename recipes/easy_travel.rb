#
# Cookbook Name:: easy_travel
# Recipes:: dynatrace
# will install Easy Travel
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'

include_recipe 'dynatrace::node_info'
include_recipe 'java'
include_recipe 'dynatrace::prerequisites'
include_recipe 'dynatrace::dynatrace_user'
include_recipe 'dynatrace::agents_package'
name = 'Easy Travel'

if platform_family?('debian', 'fedora', 'rhel')
  installer_prefix_dir = node['easy_travel']['linux']['installer']['prefix_dir']
  installer_file_name  = node['easy_travel']['linux']['installer']['file_name']
  installer_file_url   = node['easy_travel']['linux']['installer']['file_url']

  installer_cache_dir = "#{Chef::Config['file_cache_path']}/easy_travel"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
  symlink = node['easy_travel']['linux']['installer']['link']
  version = node['easy_travel']['installer']['version']

  app_arch = node['easy_travel']['installer']['arch']
  # See http://stackoverflow.com/questions/8328250/centos-64-bit-bad-elf-interpreter
  # NOTE: Even if Easy Travel app may be a 64 bit version, as of now the internal Apache server is always a 32 bit
  # version so we always have to install this package
  package 'glibc.i686' do
    action :install
  end

  easytravel_owner = node['easy_travel']['owner']
  easytravel_group = node['easy_travel']['group']

  user "Create user '#{easytravel_owner}'" do
    username   easytravel_owner
    supports :manage_home=>true
    action   :create
  end

  group "Create group '#{easytravel_group}'" do
    group_name easytravel_group
    members    [ easytravel_owner]
  end

  # Collect info after adding the new user. We will need info about home directory of the new user
  ohai 'Reload information about users' do
    action :reload
    plugin 'etc'
  end

  #creating tmp installer directory
  directory "Create the installer cache directory: #{installer_cache_dir}" do
	  path   installer_cache_dir
	  action :create
  end

  ruby_block "Check if #{name} already installed" do
    block do
      node.set[:easy_travel][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path)
    end
  end

  fresh_installer_action = "#{name} installer changed"
  #download installation jar file
  dynatrace_copy_or_download_file "Downloading installation jar file: #{name}" do
	  file_name       installer_file_name
	  file_url        installer_file_url
	  path            installer_path
    dynatrace_owner easytravel_owner
	  dynatrace_group easytravel_group
    notifies :run, "ruby_block[#{fresh_installer_action}]", :immediately
  end

  ruby_block "#{fresh_installer_action}" do
    block do
      node.set[:easy_travel][:installation][:is_required] = true
    end
    action :nothing
  end

  ruby_block "Extract the installation target directory from #{installer_path}" do
    block do
      node.set[:easy_travel][:installation][:target_dir] = Dynatrace::Helpers.get_install_dir_from_installer(installer_path)
    end
  end

  #creating installation directory
  directory "Create the installation directory #{installer_prefix_dir}" do
	  path      installer_prefix_dir
	  owner     easytravel_owner unless ::File.exist?(installer_prefix_dir)
	  group     easytravel_group unless ::File.exist?(installer_prefix_dir)
	  recursive true
	  action    :create
	  only_if { node[:easy_travel][:installation][:is_required] }
  end

  #perform installation of Easy Travel
  dynatrace_run_jar_installer "#{name}" do
	  installer_path       installer_path
	  installer_prefix_dir installer_prefix_dir
    # find_installer_folder "true"
    # cache_path           installer_cache_dir
    target_symlink       symlink
	  jar_input_sequence   "\\nY\\nY\\nY"
    dynatrace_owner      easytravel_owner
	  dynatrace_group      easytravel_group
	  only_if { node[:easy_travel][:installation][:is_required] }
  end

  config_path = "#{installer_prefix_dir}/#{symlink}/resources/easyTravelConfig.properties"
  config_path_training = "#{installer_prefix_dir}/#{symlink}/resources/easyTravelTrainingConfig.properties"

  #switch to training mode - we want to inject agents ourselves
  remote_file  'Switch to training mode' do
    path config_path
    source "file://#{config_path_training}"
  end

  #####################################################################################################
  # Inject Apache WebServer agent
  httpconf_tmp_path = "#{installer_prefix_dir}/#{symlink}/resources/custom_httpd.conf"
  template httpconf_tmp_path do
    source 'easy_travel/httpd.conf.erb'
    owner  easytravel_owner
    group  easytravel_group
    mode   '0644'
    variables(lazy {
      {
        :easy_travel_install_prefix => installer_prefix_dir,
        :version => version,
        :home_dir => node['etc']['passwd'][easytravel_owner]['dir'],
        :easy_travel_install_dir => node[:easy_travel][:installation][:target_dir]
      }
    })
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

  #####################################################################################################
  # Inject Java agents

  # As for now the Java VM bundled with Easy Travel is 32-bit
  agent_path = node['dynatrace']['java_agent']['linux'][app_arch]['agent_path']

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
      Dynatrace::Helpers.file_replace_line(config_path, 'config\.backendJavaopts=', "#{backendJavaOpts}")
      Dynatrace::Helpers.file_replace_line(config_path, 'config\.frontendJavaopts=', "#{frontendJavaOpts}")
    end
  end

  #####################################################################################################
  autostartScenarioGroup = node['easy_travel']['autostartScenarioGroup']
  autostartScenario = node['easy_travel']['autostartScenario']

  if not autostartScenario.nil? and not autostartScenarioGroup.nil?
    ruby_block "Setting autostart scenario to #{autostartScenarioGroup}:#{autostartScenario}" do
      block do
        Dynatrace::Helpers.file_replace_line(config_path, 'config\.autostartGroup=', "config.autostartGroup=#{autostartScenarioGroup}")
        Dynatrace::Helpers.file_replace_line(config_path, 'config\.autostart=', "config.autostart=#{autostartScenario}")
      end
    end
  end

  ruby_block "Stop any running instance of #{name}" do
    block do
      Dynatrace::Helpers.stop_processes(node['easy_travel']['proc_pattern'], nil, node['platform_family'], 120)
    end
  end

  execute "Start installed program #{name}" do
    command "#{installer_prefix_dir}/#{symlink}/weblauncher/weblauncher.sh&"
    user easytravel_owner
  end

  # Wait for the weblauncher console port (8094) and the Apache Web server proxy port (8079) to be opened
  [8094, 8079].each do |port|
    ruby_block "Waiting for port #{port} to become available" do
      block do
        Dynatrace::Helpers.wait_until_port_is_open(port)
      end
    end
  end

else
	# Unsupported platform
	raise 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be installed.'
end
