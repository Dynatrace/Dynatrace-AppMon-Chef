#
# Cookbook Name:: upgrade_system
# Recipes:: dynatrace
# will upgrade system 
# Copyright 2016, dynatrace
#
  name = 'Upgrade System'
  include_recipe 'dynatrace::node_info'

  node_platform = node['platform']              # "amazon"
  node_platform_version = node['platform_version']      # "2016.03"
  node_os = node['os']                    # "linux"
  node_os_version = node['os_version']            # "4.4.5-15.26.amzn1.x86_64"
  node_kernel_machine = node['kernel']['machine']       # "x86_64"
  node_kernel_processor = node['kernel']['processor']     # "x86_64"
  upgrade_system = node['upgrade']['system']
    
  if upgrade_system == 'yes'
      if platform_family?('fedora', 'rhel')
          execute "Update system" do
              command "yum update -y"
          end
      elsif platform_family?('debian')
        execute "Update package index" do
            command "apt-get update -y"
        end
        execute "Update system" do
            command "apt-get upgrade -y"
        end
      else
        puts "Unsupported platform family. System will not be upgraded."
      end
  else
      puts 'System will not be upgraded - default settings has been overridden.'
  end
