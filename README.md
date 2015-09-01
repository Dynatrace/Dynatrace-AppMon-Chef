# dynatrace Cookbook

This Chef cookbook installs and configures the Dynatrace Application Monitoring solution.

## Requirements

Requires Chef 11 or higher.

## Recipes

### default

Installs the Dynatrace Server. Please refer to the `server` Chef Recipe below.

### agents_package

*Installs the Dynatrace Agents package.*

Download the Dynatrace Agents package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.jar` (Linux) or as `dynatrace-agents.msi` (Windows) in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['agents_package'][...]['installer']['file_url']` attribute. Please refer to `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::agents_package]` in a runlist.

**Note:** this recipe merely makes the Dynatrace Agents available, but it does not configure your application to actually load any. See the `java_agent` recipe for an example that does.

### apache_wsagent

*Installs the Dynatrace WebServer Agent for the Apache HTTP Server.*

Download the Dynatrace WebServer Agent installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-wsagent.tar` in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['wsagent_package']['linux']['installer']['file_url']` attribute. Please refer to `attributes/apache_wsagent.rb` and `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::apache_wsagent]` in a runlist.

**Note:** you will have to restart the web server after placing the agent.

### collector

*Installs the Dynatrace Collector.*

Download the Dynatrace Collector installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-collector.jar` in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['collector']['linux']['installer']['file_url']` attribute. Please refer to `attributes/collector.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::collector]` in a runlist.

**Note:** make sure that attributes related to the Collector's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT60/Collector+Configuration#CollectorConfiguration-MemoryConfiguration) section of the [Collector Configuration](https://community.dynatrace.com/community/display/DOCDT60/Collector+Configuration) documentation.

### dotnet_agent

*Installs the Dynatrace .NET Agent.*

Download the Dynatrace Agents package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.jar` (Linux) or in `dynatrace-agents.msi` (Windows) in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['agents_package'][...]['installer']['file_url']` attribute.  Please refer to `attributes/dotnet_agent.rb` and `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::dotnet_agent]` in a runlist.

### iis_wsagent

*Installs the Dynatrace WebServer Agent for the Microsoft IIS Server.*

Download the Dynatrace WebServer Agent installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.msi`in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['wsagent_package']['windows']['installer']['file_url']` attribute. Please refer to `attributes/iis_wsagent.rb` and `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::iis_wsagent]` in a runlist.

### java_agent

*Installs the Dynatrace Agent Java Agent.*

Download the Dynatrace Agent package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-agents.jar` in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['agents_package']['linux']['installer']['file_url']` attribute. Please refer to `attributes/java_agent.rb` and `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::java_agent]` in a runlist.

**Note:** this recipe makes the Java Agent available to a Java Virtual Machine by injecting an appropriate [-agentpath](https://community.compuwareapm.com/community/display/DOCDT60/Java+Agent+Configuration) option into an environment variable, e.g. `JAVA_OPTS`, inside a file (typically an executable script). It is assumed that this script either executes the Java process directly or is sourced by another script before the Java process gets executed. You will have to restart the application after placing the agent.

### memory_analysis_server

Download the Dynatrace Memory Analysis Server installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-analysisserver.jar` in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['memory_analysis_server']['linux']['installer']['file_url']` attribute. Please refer to `attributes/memory_analysis_server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::memory_analysis_server]` in a runlist.

**Note:** make sure that attributes related to the Analysis Server's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT62/Memory+Analysis+Server+Configuration#MemoryAnalysisServerConfiguration-MemoryConfiguration) section of the [Memory Analysis Server Configuration](https://community.dynatrace.com/community/display/DOCDT62/Memory+Analysis+Server+Configuration) documentation.

### server

*Installs the Dynatrace Server.*

Download the Dynatrace Server installer from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace.jar` in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['server']['linux']['installer']['file_url']` attribute. Please refer to `attributes/server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::server]` in a runlist.

### server_license

*Installs the Dynatrace Server License.*

Place the Dynatrace Server License as `dynatrace-license.key` in the cookbook's `files` directory. Alternatively, you can make the license available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['server']['license']['file_url']` attribute. Please refer to `attributes/server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::server_license]` in a runlist.

### wsagent_package

*Installs the Dynatrace WebServer Agent package.*

Download the Dynatrace WebServer Agent package from [downloads.dynatrace.com](http://downloads.dynatrace.com) and place the artifact as `dynatrace-wsagent.jar` (Linux) or as `dynatrace-wsagent.msi` (Windows) in the cookbook's `files` directory. Alternatively, you can make the installer available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['wsagent_package'][...]['installer']['file_url']` attribute. Please refer to `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::wsagent_package]` in a runlist.

**Note:** this recipe merely makes the Dynatrace WebServer Agent available, but it does not configure your web server to actually load it. See the `apache_wsagent` and `iis_agent`recipes for examples.

## Testing

We use [Test Kitchen](http://kitchen.ci) to automatically test our automated deployments with [Serverspec](http://serverspec.org) and [RSpec](http://rspec.info/):

1) Install Test Kitchen and its dependencies from within the project's directory:

```
gem install bundler
bundle install
```

2) Run all tests

```
kitchen test
```

By default, we run our tests inside [Docker](https://www.docker.com/) containers as this considerably speeds up testing time (see `.kitchen.yml`, requires Ruby 2.2+). Alternatively, you may as well run these tests in virtual machines based on [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/) (see `.kitchen.vagrant.yml`).

## Platforms

### Linux

- CentOS 6.5
- Debian 7.4
- Ubuntu 12.04

### Windows

- Windows 2012 R2

## Questions?

Feel free to post your questions on the Dynatrace Community's [Continuous Delivery Forum](https://answers.dynatrace.com/spaces/148/open-q-a_2.html?topics=continuous%20delivery).

## License

Licensed under the MIT License. See the LICENSE file for details.
[![analytics](https://www.google-analytics.com/collect?v=1&t=pageview&_s=1&dl=https%3A%2F%2Fgithub.com%2FdynaTrace&dp=%2FDynatrace-Chef&dt=Dynatrace-Chef&_u=Dynatrace~&cid=github.com%2FdynaTrace&tid=UA-54510554-5&aip=1)]()