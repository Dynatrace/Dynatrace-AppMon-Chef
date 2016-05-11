name 'dynatrace'
maintainer 'Martin Etmajer'
maintainer_email 'martin.etmajer@dynatrace.com'
license 'MIT'
description 'Installs the Dynatrace Application Monitoring solution.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '6.3.2'
source_url 'https://github.com/Dynatrace/Dynatrace-Chef'
issues_url 'https://github.com/Dynatrace/Dynatrace-Chef/issues'

%w( debian ubuntu redhat centos fedora amazon windows ).each do |os|
  supports os
end

depends 'apache2'
depends 'java'

recipe 'dynatrace', 'Installs the Dynatrace Server and Agents package.'
recipe 'dynatrace:agents_package', 'Installs the Dynatrace Agents package.'
recipe 'dynatrace:apache_wsagent', 'Installs the Dynatrace WebServer Agent for the Apache HTTP Server.'
recipe 'dynatrace:collector', 'Installs the Dynatrace Collector.'
recipe 'dynatrace:dotnet_agent', 'Installs the Dynatrace .NET Agent.'
recipe 'dynatrace:dynatrace_user', 'Installs the Dynatrace system user.'
recipe 'dynatrace:iis_wsagent', 'Installs the Dynatrace WebServer Agent for the Microsoft IIS Server.'
recipe 'dynatrace:java_agent', 'Installs the Dynatrace Agent Java Agent.'
recipe 'dynatrace:memory_analysis_server', 'Installs the Dynatrace Memory Analysis Server.'
recipe 'dynatrace:server', 'Installs the Dynatrace Server.'
recipe 'dynatrace:server_license', 'Installs the Dynatrace Server License.'
recipe 'dynatrace:wsagent_package', 'Installs the Dynatrace WebServer Agent package.'
recipe 'dynatrace:easy_travel', 'Installs the Easy Travel.'
recipe 'dynatrace:easy_travel_uninstall', 'Uninstalls the Easy Travel.'
