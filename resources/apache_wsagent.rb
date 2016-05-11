#
# Cookbook Name:: dynatrace
# Resource:: apache_wsagent
#
# Author:: Piotr Ozieblo
# Copyright:: Copyright 2016, Dynatrace
#

actions :inject 
default_action :inject

property :apache_config_file_path, String
property :agent_path, String

action :inject do
  recipe_eval do
    run_context.include_recipe "dynatrace::wsagent_package"
  end
  ruby_block "Inject the #{name} into Apache HTTPD's config file" do
    block do
      Dynatrace::Helpers.file_append_line(apache_config_file_path, "LoadModule dtagent_module \"#{agent_path}\"")
    end
  end
end


