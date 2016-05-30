#
# Cookbook Name:: upgrade_system
# Recipes:: dynatrace
# will upgrade system 
# Copyright 2016, dynatrace
#
    name = 'Upgrade System'

    node_platform = node['platform']              # "amazon"
    node_platform_version = node['platform_version']      # "2016.03"
    node_os = node['os']                    # "linux"
    node_os_version = node['os_version']            # "4.4.5-15.26.amzn1.x86_64"
    node_kernel_machine = node['kernel']['machine']       # "x86_64"
    node_kernel_processor = node['kernel']['processor']     # "x86_64"
    upgrade_system = node['upgrade']['system']
      
    log 'Platform:' + node_platform + "  version:" + node_platform_version + "  os:" + node_os.to_s + "  os_version:" + node_os_version.to_s + '  machine:' + node_kernel_machine.to_s + ' upgrade system:' + upgrade_system
    
    if upgrade_system == 'yes'
        if platform_family?('fedora', 'rhel')
            execute "Update system" do
                command "yum update -y"
            end
        elsif platform_family?('debian')
          execute "Update system" do
              command "aptitude update -y"
          end
          execute "Upgrade system" do
              command "aptitude full-upgrade -y"
          end
        else
            raise "Unsupported platform family."
        end
    else
        raise 'System will not be upgraded - default settings has been overwritten.'
    end
