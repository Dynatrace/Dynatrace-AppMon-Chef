name 'dynatrace'
maintainer 'Martin Etmajer'
maintainer_email 'martin.etmajer@dynatrace.com'
license 'MIT'
description 'Installs Dynatrace Application Monitoring'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.7'
source_url 'https://github.com/Dynatrace/Dynatrace-Cookbook'
issues_url 'https://github.com/Dynatrace/Dynatrace-Cookbook/issues'

%w( debian ubuntu redhat centos fedora amazon windows ).each do |os|
  supports os
end

recipe 'dynatrace', 'Installs the Dynatrace Server and Agents package.'
recipe 'dynatrace:agents_package', 'Installs the Dynatrace Agents package.'
recipe 'dynatrace:apache_wsagent', 'Installs the Dynatrace WebServer Agent for the Apache HTTP Web Server.'
recipe 'dynatrace:collector', 'Installs the Dynatrace Collector.'
recipe 'dynatrace:dynatrace_user', 'Installs the Dynatrace system user.'
recipe 'dynatrace:java_agent', 'Installs the Dynatrace Agent Java Agent.'
recipe 'dynatrace:server', 'Installs the Dynatrace Server.'
recipe 'dynatrace:wsagent_package', 'Installs the Dynatrace WebServer Agent package.'
