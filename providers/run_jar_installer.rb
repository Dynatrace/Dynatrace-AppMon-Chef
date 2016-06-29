#
# Cookbook Name:: dynatrace
# Providers:: run_jar_installer
#
# Copyright 2016, Dynatrace
#

action :run do
  jar_cmd = !new_resource.jar_input_sequence.nil? ? "echo -e '#{new_resource.jar_input_sequence}'" : 'yes'
  jar_cmd << " | java -jar #{new_resource.installer_path}"

  bash "Install the #{new_resource.name}" do
    code "#{jar_cmd}"
    cwd  ::File.dirname(new_resource.installer_path)
  end
	  
  if new_resource.target_dir.nil?
    new_resource.target_dir = Dynatrace::Helpers.get_install_dir_from_installer(new_resource.installer_path, :jar)
    puts 'new_resource.target_dir was nil, now is:' + new_resource.target_dir
  else
    puts 'new_resource.target_dir is:' + new_resource.target_dir
  end

  if new_resource.find_installer_folder.nil?			#legal way without determine cache installation folder by list subfolders
    ruby_block "Determine the #{new_resource.name}'s installation directory" do
      block do
  	  installation_path = "#{new_resource.installer_prefix_dir}/#{new_resource.target_dir}"
  
        res = resources("execute[Move the installation directory to #{new_resource.installer_prefix_dir}]")
        res.command get_mv_install_dir_cmd(::File.dirname(new_resource.installer_path) << "/#{new_resource.target_dir}", new_resource.installer_prefix_dir)
  
        res = resources("execute[Change ownership of the installation directory]")
        res.command get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)
  
        res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}]")
        res.to installation_path
      end
    end
  else
    cache_et_folder_files = Array.new
    ruby_block "Determine the #{new_resource.name}'s installation directory, new_resource.target_dir=#{new_resource.target_dir},  installer_prefix_dir=#{new_resource.installer_prefix_dir}" do
      block do
        puts 'new_resource.installer_prefix_dir is:' + new_resource.installer_prefix_dir
  	    installation_path = "#{new_resource.installer_prefix_dir}/#{new_resource.target_dir}"
  	    
        cache_inst_dir0 = ""
        cache_inst_dir = ""
  	    if !new_resource.find_installer_folder.nil?
  	    	#determine physical cache installation directory
  	      if new_resource.cache_path.nil?
            cache_inst_dir0 = "/var/chef/cache/#{new_resource.target_symlink}/#{new_resource.target_dir}"
  	      else
            cache_inst_dir0 = "#{new_resource.cache_path}/#{new_resource.target_dir}"
  	      end
          cache_inst_dir = cache_inst_dir0 + '*'
    	    puts "determine physical cache installation directory in: #{cache_inst_dir}"
          cache_et_folder_files = Dir["#{cache_inst_dir}"]
          puts "new_resource.installer_path=#{new_resource.installer_path}"
          puts "new_resource.cache_path=#{new_resource.cache_path}"
          puts
          puts 'Found ' + cache_et_folder_files.size.to_s + ' matching files.'
          cache_et_folder = cache_et_folder_files[0]
          puts "cache_et_folder=#{cache_et_folder}"
          puts "new_resource.target_symlink=#{new_resource.target_symlink}"
          puts "cache_inst_dir0=#{cache_inst_dir0}"
          puts
#          puts "#{recipe_name}"		#doesn't work
#          puts
          base_name = new_resource.target_symlink + cache_et_folder.delete("#{new_resource.cache_path}/")
          puts "Installation cache directory is: #{cache_et_folder} and its basename is: #{base_name}"
          installation_path = "#{new_resource.installer_prefix_dir}/#{base_name}"
        end
        puts 'installation_path is:' + installation_path
  
        res = resources("execute[Move the installation directory to #{new_resource.installer_prefix_dir}]")
        res.command get_mv_install_dir_cmd(cache_et_folder, new_resource.installer_prefix_dir)
  
        res = resources("execute[Change ownership of the installation directory]")
        res.command get_chown_recursively_cmd(installation_path, new_resource.dynatrace_owner, new_resource.dynatrace_group)
  
        res = resources("link[Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}]")
        res.to installation_path
      end
    end
  end

  execute "Move the installation directory to #{new_resource.installer_prefix_dir}" do
    command nil
  end

  execute "Change ownership of the installation directory" do
    command nil
  end

  link "Create a symlink of the #{new_resource.name} installation to #{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}" do
    target_file "#{new_resource.installer_prefix_dir}/#{new_resource.target_symlink}"
    owner new_resource.dynatrace_owner
    group new_resource.dynatrace_group
    to nil
  end
end

def get_chown_link_cmd(dir, owner, group)
  return "chown -h #{owner}:#{group} #{dir}"
end

def get_chown_recursively_cmd(dir, owner, group)
  return "chown -R #{owner}:#{group} #{dir}"
end

def get_mv_install_dir_cmd(src, dest)
  puts 'mv_install_dir_cmd src:' + src + ' dest:' +dest
  return "rsync -a #{src} #{dest} && rm -rf #{src}"
end

def get_rm_install_dir_cmd(dir)
  return "rm -r -f #{dir}"
end

def get_start_cmd(dest)
  return "#{dest}"
end
