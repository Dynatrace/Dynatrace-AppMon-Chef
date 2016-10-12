#
# Cookbook Name:: dynatrace
# Libraries:: package_helpers
#
# Copyright 2016, Dynatrace
#

require 'tmpdir'

module Dynatrace
  # Helper methods that manipulate jar an tar packages
  module PackageHelpers
    def self.get_install_dir_from_installer_tar(installer_path)
      # extract the dynatrace.x.y.z directory name from the contained installer shell script
      install_dir = nil
      Dir.mktmpdir do |tmpdir|
        install_dir = Mixlib::ShellOut.new("tar -xf #{installer_path} -C #{tmpdir} && cd #{tmpdir} && head -n 10 dynatrace*.sh | grep mkdir | cut -d ' ' -f 2", :cwd => File.dirname(installer_path)).run_command.stdout.strip
        if install_dir.empty?
          Dir.chdir
          dynatrace_dirs = Dir["#{tmpdir}/dynatrace*"]
          dynatrace_dirs.each do |elem|
            if File.directory?(elem)
              install_dir = File.basename elem
              break
            end
          end
        end
      end
      install_dir
    end

    def self.get_install_dir_from_installer_jar(installer_path)
      # extract the Manifest file
      cwd = File.dirname(installer_path)
      Mixlib::ShellOut.new("jar -xf #{installer_path} META-INF/MANIFEST.MF", :cwd => cwd).run_command

      prefix, ver_rev, ver_maj, ver_min = get_version_from_manifest "#{cwd}/META-INF/MANIFEST.MF"
      # Use a default prefix if prefix attribute not present in the Manifest file
      # The logic below is taken from the AbstractInstaller class in the Dynatrace jars
      install_dir = prefix ? prefix : "dynatrace-#{ver_maj}.#{ver_min}#{ver_rev}"

      # remove temporary directories
      Mixlib::ShellOut.new('rm -rf META-INF', :cwd => File.dirname(installer_path)).run_command

      install_dir
    end

    # private_class_method
    def self.get_version_from_manifest(file_path)
      prefix = nil
      ver_rev = '' # optional
      ver_maj = nil
      ver_min = nil
      File.open(file_path).each do |line|
        prefix = Regexp.last_match(1) if /prefix:\s*(\S+)/ =~ line
        break if prefix
        ver_maj = Regexp.last_match(1) if /version-major:\s*(\S+)/ =~ line
        ver_min = Regexp.last_match(1) if /version-minor:\s*(\S+)/ =~ line
        ver_rev = ".#{Regexp.last_match(1)}" if /version-revision:\s*(\S+)/ =~ line
      end
      [prefix, ver_rev, ver_maj, ver_min]
    end

    def self.get_install_dir_from_installer(installer_path, type = :jar)
      if type == :jar
        install_dir = get_install_dir_from_installer_jar(installer_path)
      end

      if type == :tar
        install_dir = get_install_dir_from_installer_tar(installer_path)
      end

      install_dir
    end

    def self.get_last_install_path(installer_prefix_dir)
      cmd = "find . -maxdepth 1 -name dynatrace-\\* -type d -printf \'%T@ %p\' | sort -k 1nr | cut -d\' \' -f2 | head -1 | xargs basename | xargs echo -n"
      shell = Mixlib::ShellOut.new(cmd, :cwd => installer_prefix_dir)
      shell.run_command

      "#{installer_prefix_dir}/#{shell.stdout}"
    end

    def self.requires_installation?(installer_prefix_dir, installer_path, component_path_part = '', type = :jar)
      return false unless File.exist?(installer_path)
      install_dir = get_install_dir_from_installer(installer_path, type)
      # puts "install_dir is #{install_dir}"
      path_to_check = "#{installer_prefix_dir}/#{install_dir}/#{component_path_part}"
      # puts "path_to_check is #{path_to_check}"
      !(Dir.exist?(path_to_check) || File.exist?(path_to_check))
    end

    private_class_method :get_version_from_manifest
  end
end
