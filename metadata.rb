name 'dynatrace-appmon'
maintainer 'Martin Etmajer'
maintainer_email 'martin.etmajer@dynatrace.com'
license 'MIT'
description 'Installs the Dynatrace Application Monitoring solution.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.8'
source_url 'https://github.com/Dynatrace/Dynatrace-AppMon-Chef'
issues_url 'https://github.com/Dynatrace/Dynatrace-AppMon-Chef/issues'
chef_version '>= 12.1'

%w( debian ubuntu redhat centos fedora amazon windows ).each do |os|
  supports os
end

depends 'apache2'
depends 'java'
depends 'line', '>= 0.6.3'

recipe 'dynatrace', 'Installs the Dynatrace Server and Agents package.'

recipe 'dynatrace:agents_package', 'Installs the Dynatrace Agents package.'
recipe 'dynatrace:agents_package_uninstall', 'Uninstalls the Dynatrace Agents package.'

recipe 'dynatrace:apache_wsagent', 'Installs the Dynatrace WebServer Agent for the Apache HTTP Server.'
recipe 'dynatrace:apache_wsagent_uninstall', 'Uninstalls the Dynatrace WebServer Agent for the Apache HTTP Server.'

recipe 'dynatrace:collector', 'Installs the Dynatrace Collector.'
recipe 'dynatrace:collector_uninstall', 'Uninstalls the Dynatrace Collector.'

recipe 'dynatrace:dynatrace_user', 'Installs the Dynatrace system user.'
recipe 'dynatrace:dynatrace_user_uninstall', 'Uninstalls the Dynatrace system user.'

recipe 'dynatrace:server', 'Installs the Dynatrace Server.'
recipe 'dynatrace:server_uninstall', 'Uninstalls the Dynatrace Server.'

recipe 'dynatrace:wsagent_package', 'Installs the Dynatrace WebServer Agent package.'
recipe 'dynatrace:wsagent_package_uninstall', 'Uninstalls the Dynatrace WebServer Agent package.'

recipe 'dynatrace:dotnet_agent', 'Installs the Dynatrace .NET Agent.'
recipe 'dynatrace:iis_wsagent', 'Installs the Dynatrace WebServer Agent for the Microsoft IIS Server.'
recipe 'dynatrace:java_agent', 'Installs the Dynatrace Agent Java Agent.'
recipe 'dynatrace:memory_analysis_server', 'Installs the Dynatrace Memory Analysis Server.'
recipe 'dynatrace:server_license', 'Installs the Dynatrace Server License.'
recipe 'dynatrace:upgrade_system', 'Updates the OS.'
