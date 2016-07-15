#
# Cookbook Name:: easy_travel_windows
# Recipes:: dynatrace
# will install Easy Travel
# Copyright 2016, dynatrace
#
require 'json'
require 'net/https'

include_recipe 'dynatrace::node_info'
include_recipe 'java'
if !platform_family?('windows')
  include_recipe 'dynatrace::helpers'
end
include_recipe 'dynatrace::dynatrace_user'
if !platform_family?('windows')
  include_recipe 'dynatrace::agents_package'
end
name = 'Easy Travel'

if platform_family?('windows')
    
  #TODO doesn't work on windows...
#  require 'aws'
#  require 'windows'
    
  installer_prefix_dir = node['easy_travel']['windows']['installer']['prefix_dir']
  installer_file_name  = node['easy_travel']['windows']['installer']['file_name']
  installer_file_url   = node['easy_travel']['windows']['installer']['file_url']
  
  installer_cache_dir = "#{Chef::Config['file_cache_path']}/easy_travel"
  installer_path      = "#{installer_cache_dir}/#{installer_file_name}"
  
  symlink = node['easy_travel']['linux']['installer']['link']
  version = node['easy_travel']['installer']['version']
  
  app_arch = node['easy_travel']['installer']['arch']
  # See http://stackoverflow.com/questions/8328250/centos-64-bit-bad-elf-interpreter
  # NOTE: Even if Easy Travel app may be a 64 bit version, as of now the internal Apache server is always a 32 bit
  # version so we always have to install this package
#  package 'glibc.i686' do
#    action :install
#  end
  
  #here Easy Travel is installed on Windows (see description in easy_travel_attributes.rb file)
  destination_folder = node['easy_travel']['windows']['installer']['folder']
  user_destination_folder = node['easy_travel']['windows']['installer']['user_folder']
    
  easytravel_owner = node['easy_travel']['owner']
  easytravel_group = node['easy_travel']['group']
  
  user "Create user '#{easytravel_owner}'" do
    username   easytravel_owner
    supports :manage_home=>true
    action   :create
  end
  
  group "Create group '#{easytravel_group}'" do
    ignore_failure true
    group_name easytravel_group
    members    [easytravel_owner]
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
  
  #TODO fix Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, '', :msi) for :msi
#  ruby_block "Check if #{name} already installed" do
#    block do
#      node.set[:easy_travel][:installation][:is_required] = Dynatrace::Helpers.requires_installation?(installer_prefix_dir, installer_path, '', :msi)
#    end
#  end
  node.set[:easy_travel][:installation][:is_required] = true
  
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
  
  easy_travel_install_log = installer_cache_dir + '/easy_travel_install.log'
  dynatrace_run_msi_installer "#{name}" do
    name                    installer_file_name
    source_installer_dir    installer_cache_dir
    log                     easy_travel_install_log 
    ignore_failure          true
    timeout                 180               #3min = 3*60
  end
  
  puts 'after run_msi_installer'
  
  config_path = "#{destination_folder}/resources/easyTravelConfig.properties"
  config_path_training = "#{destination_folder}/resources/easyTravelTrainingConfig.properties"
  
  #switch to training mode - we want to inject agents ourselves
  remote_file  "Switch to training mode config_path=#{config_path} config_path_training=#{config_path_training}" do
    path config_path
    source "file://#{config_path_training}"
  end
  
  ####################################################################################################
  # Inject Apache WebServer agent
  httpconf_tmp_path = "#{destination_folder}/resources/custom_httpd.conf"
  template httpconf_tmp_path do
    source 'easy_travel/httpd.conf.erb'
    owner  easytravel_owner
    group  easytravel_group
    mode   '0644'
    action :create
  end
  
  ruby_block "Changing #{httpconf_tmp_path} file." do
    block do
      Dynatrace::Helpers.file_append_or_replace_line(httpconf_tmp_path, "ServerRoot \"//weblauncher/../apache2.2/Linux\"", "ServerRoot #{destination_folder}/apache2.2/Windows")
      Dynatrace::Helpers.file_append_or_replace_line(httpconf_tmp_path, "DocumentRoot \"//weblauncher/../apache2.2/htdocs\"", "DocumentRoot #{destination_folder}/apache2.2/htdocs\n" +
                                                                                                                            "LoadModule log_rotate_module modules/mod_log_rotate.dll\n" +
                                                                                                                            "RotateLogs On\n" +
                                                                                                                            "RotateLogsLocalTime On\n" +
                                                                                                                            "RotateInterval 3600\n"
                                                                                                                            )
      
      Dynatrace::Helpers.file_append_or_replace_line(httpconf_tmp_path, "ErrorLog '|\"//weblauncher/../apache2.2/Linux/bin/rotatelogs\" \"/.dynaTrace/easyTravel /easyTravel/log/error_%H.log\" 3600'", 
                                                                        "ErrorLog #{user_destination_folder}/.dynaTrace/easyTravel #{version}/easyTravel/log/error.log")
                                                                        
      Dynatrace::Helpers.file_append_or_replace_line(httpconf_tmp_path, "TypesConfig \"/.dynaTrace/easyTravel /easyTravel/config/mime.types\"", 
                                                                        "TypesConfig #{user_destination_folder}/.dynaTrace/easyTravel #{version}/easyTravel/config/mime.types")
                                                                        
      Dynatrace::Helpers.file_append_or_replace_line(httpconf_tmp_path, "PidFile \"/.dynaTrace/easyTravel /easyTravel/tmp/httpd.pid\"", 
                                                                        "PidFile #{user_destination_folder}/.dynaTrace/easyTravel #{version}/easyTravel/tmp/httpd.pid")
    end
  end

    
  node.set['dynatrace']['apache_wsagent']['arch'] = 'x86'
  node.set['dynatrace']['apache_wsagent']['apache']['config_file_path'] = httpconf_tmp_path
    
  #TODO doesn't work on windows...
  #include_recipe 'dynatrace::apache_wsagent'
  
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
  
#  toExec = "start.vbs"
#  toExec = "start.bat"
#  cmd = "#{destination_folder}/weblauncher/"
#  execute "Start installed program using command: #{toExec}  in #{cmd}" do
#    command toExec
#    cwd "#{cmd}"
##    live_stream true
##    user easytravel_owner
#  end
  
#  # Wait for the weblauncher console port (cd ) and the Apache Web server proxy port (8079) to be opened
#  [8094, 8079].each do |port|
#    ruby_block "Waiting for port #{port} to become available" do
#      block do
#        Dynatrace::Helpers.wait_until_port_is_open(port)
#      end
#    end
#  end
#  
    
else
  # Unsupported platform
  raise 'Unsuppored platform. Only Red Hat Enterprise Linux, Debian and Fedora are supported. Easy Travel will not be installed.'
end
