#
# Cookbook Name:: dynatrace
# Resources:: run_msi_installer
#
# Copyright 2016, Dynatrace
#
# dynatrace-easytravel-windows-x86_64-2.0.0.2347.msi /quiet /qn /norestart /log C:\chef\cache\easy_travel\easy_travel.log


actions :run
default_action :run

attribute :name,                  :kind_of => String, :default => nil
attribute :source_installer_dir,  :kind_of => String, :default => nil
attribute :group,                 :kind_of => String, :default => nil
attribute :user,                  :kind_of => String, :default => nil
attribute :quiet,                 :kind_of => String, :default => '/quiet'
attribute :qn,                    :kind_of => String, :default => '/qn'
attribute :norestart,             :kind_of => String, :default => '/norestart'
attribute :log,                   :kind_of => String, :default => nil
attribute :timeout,               :kind_of => Integer, :default => 600      #10 min
attribute :ignore_failure,        :kind_of => [FalseClass, TrueClass], :default => false

