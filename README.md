# dynatrace Cookbook

This Chef cookbook installs and configures the Dynatrace Application Monitoring 7.0 solution.

[![Build Status](https://jenkins-01.eastus.cloudapp.azure.com/job/dynatrace-cookbook/badge/icon)](https://jenkins-01.eastus.cloudapp.azure.com/job/dynatrace-cookbook/)

## Requirements

Requires Chef 12 or higher.

## Recipes

### default

Installs the Dynatrace Server. Please refer to the `server` Chef Recipe below.

### agents_package

*Installs the Dynatrace Agents package.*

This recipe downloads and installs the most recent version of the Dynatrace Agents package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['agents_package'][$platform]['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-agent.jar` (Linux) or as `dynatrace-agent.msi` (Windows) in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::agents_package]` in a runlist and override attributes as required.

**Note:** this recipe merely makes the Dynatrace Agents available, but it does not configure your application to actually load any. See the `java_agent` recipe for an example that does.

### agents_package_uninstall

This recipe uninstalls the Dynatrace Agents package installed by the `agents_package` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by the `agents_package` recipe.
**Note:** as part of the uninstallation process the `opt/dynatrace` directory is deleted which is by default shared by other Dynatrace components (e.g. `wsagent_package`).

### apache_wsagent

*Installs the Dynatrace WebServer Agent for the Apache HTTP Server.*

This recipe downloads and installs the most recent version of the Dynatrace WebServer Agent package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com) and integrates the agent with the Apache HTTP Server. The default download link can be overridden via the `node['dynatrace']['wsagent_package']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-wsagent.tar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/apache_wsagent.rb` and `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::apache_wsagent]` in a runlist and override attributes as required.

**Note:** you will have to restart the web server after placing the agent.

### apache_wsagent_uninstall

This recipe remove the agent from the Apache HTTP Server configuration file and uninstalls the Dynatrace WebServer Agent package installed by the `apache_wsagent` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by the `apache_wsagent` recipe.
**Note:** as part of the uninstallation process the `opt/dynatrace` directory is deleted which is by default shared by other Dynatrace components (e.g. `agents_package`).

### collector

*Installs the Dynatrace Collector.*

This recipe downloads and installs the most recent version of the Dynatrace Collector from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['collector']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-collector.jar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/collector.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::collector]` in a runlist and override attributes as required.

**Note:** make sure that attributes related to the Collector's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT65/Set+up+Collectors#SetupCollectors-ConfigureMemory) section of the [Collector Configuration](https://community.dynatrace.com/community/display/DOCDT65/Set+up+Collectors) documentation.

### collector_uninstall

This recipe uninstalls the Dynatrace Collector package installed by the `collector` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by `collector` recipe.

### dotnet_agent

*Installs the Dynatrace .NET Agent.*

This recipe downloads and installs the most recent version of the Dynatrace Agents package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['agents_package']['windows']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-agent.msi` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/dotnet_agent.rb` and `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::dotnet_agent]` in a runlist and override attributes as required.

### host_agent

*Installs the Host Agent package.*

This recipe downloads and installs the most recent version of the Host Agent package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can #be overridden via the `['dynatrace']['host_agent']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-hostagent.tar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/host_agent.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::host_agent]` in a runlist and override attributes as required.

### host_agent_uninstall

This recipe uninstalls the Dynatrace Host Agent package installed by the `host_package` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by the `host_package` recipe.
**Note:** as part of the uninstallation process the `opt/dynatrace` directory is deleted which is by default shared by other Dynatrace components (e.g. `agents_package`).

### iis_wsagent

*Installs the Dynatrace WebServer Agent for the Microsoft IIS Server.*

This recipe downloads and installs the most recent version of the Dynatrace WebServer Agent package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com) and integrates the agent with the Microsoft IIS Server. The default download link can be overridden via the `node['dynatrace']['wsagent_package']['windows']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-agent.msi` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/iis_wsagent.rb` and `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::iis_wsagent]` in a runlist and override attributes as required.

### java_agent

*Installs the Dynatrace Agent Java Agent.*

This recipe downloads and installs the most recent version of the Dynatrace Agents package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com) and integrates the agent with a Java process. The default download link can be overridden via the `node['dynatrace']['agents_package']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-agents.jar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/java_agent.rb` and `attributes/agents_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::java_agent]` in a runlist and override attributes as required.

**Note:** this recipe makes the Java Agent available to a Java Virtual Machine by injecting an appropriate [-agentpath](https://community.compuwareapm.com/community/display/DOCDT65/Java+Agent+Configuration) option into an environment variable, e.g. `JAVA_OPTS`, inside a file (typically an executable script). It is assumed that this script either executes the Java process directly or is sourced by another script before the Java process gets executed. You will have to restart the application after placing the agent.

**Note:** it is only possible to inject one agent on one machine using this recipe. To inject more agents it is possible to use the `resources/java_agent.rb` resource which sets the `node['dynatrace']['java_agent']['javaopts'][$agent_name]` with options to be passed to the JVM (e.g. `-agentpath:/opt/dynatrace/agent/lib64/libdtagent.so=name=BusinessBackend_easyTravel,server=dynasprint-collector.dynatracesaas.com:9998`).

### memory_analysis_server

This recipe downloads and installs the most recent version of the Dynatrace Memory Analysis Server from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['memory_analysis_server']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-analysisserver.jar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/memory_analysis_server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::memory_analysis_server]` in a runlist and override attributes as required.

**Note:** make sure that attributes related to the Analysis Server's memory configuration are set in accordance to the [Memory Configuration](https://community.dynatrace.com/community/display/DOCDT65/Set+up+a+Memory+Analysis+Server#SetupaMemoryAnalysisServer-ConfigureMemory) section of the [Memory Analysis Server Configuration](https://community.dynatrace.com/community/display/DOCDT65/Set+up+a+Memory+Analysis+Server) documentation.

### server

*Installs the Dynatrace Server.*

This recipe downloads and installs the most recent version of the Dynatrace Server from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['server']['linux']['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-server.jar` in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::server]` in a runlist and override attributes as required.

### server_uninstall

This recipe uninstalls the Dynatrace Server package installed by the `server` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by `server` recipe.

### server_license

*Installs the Dynatrace Server License.*

Place the Dynatrace Server License as `dynatrace-license.lic` in the cookbook's `files` directory. Alternatively, you can make the license available as an *HTTP* or *FTP* resource and point the Chef Recipe to the right location via the `node['dynatrace']['server']['license']['file_url']` attribute. Please refer to `attributes/server.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::server_license]` in a runlist.

### server_pwh_connection

*Sets connection to the Performance Warehouse.*

This recipe sets the connection to the Performance Warehouse on the Dynatrace Server. This recipe assumes the Dynatrace Server is up and running. Please refer to the `.kitchen.yml` file for example of usage.

**Note:** This recipe will work after installing the Server License (see `server_license` recipe).

### server_ldap_config

*Configures LDAP connection.*

This recipe configures connection to LDAP through RESTful API. This recipe assumes the Dynatrace Server is up and running. Please refer to the `.kitchen.yml` file for example of usage.

### server_users

*Configures server user accounts.*

This recipe creates/updates Dynatrace Server user accounts through RESTful API. This recipe assumes the Dynatrace Server is up and running. The user account configuration is passed as node attributes. Please refer to the `.kitchen.yml` file for example of usage.

### server_user_groups

*Configures server groups.*

This recipe creates/updates Dynatrace Server groupsthrough RESTful API. This recipe assumes the Dynatrace Server is up and running. The group configuration is passed as node attributes. Please refer to the `.kitchen.yml` file for example of usage.

### wsagent_package

*Installs the Dynatrace WebServer Agent package.*

This recipe downloads and installs the most recent version of the Dynatrace WebServer Agent package from [http://downloads.dynatracesaas.com](http://downloads.dynatracesaas.com). The default download link can be overridden via the `node['dynatrace']['wsagent_package'][$platform]['installer']['file_url']` attribute. Alternatively, you can place the installer artifact as `dynatrace-wsagent.tar` (Linux) or `dynatrace-agent.msi` (Windows) in the cookbook's `files` directory from where it will be picked up during the installation. Please refer to `attributes/wsagent_package.rb` for a list of supported attributes. In order to have the Chef Recipe executed, include `recipe[dynatrace::wsagent_package]` in a runlist and override attributes as required.

**Note:** this recipe merely makes the Dynatrace WebServer Agent available, but it does not configure your web server to actually load it. See the `apache_wsagent` and `iis_agent`recipes for examples.

### wsagent_package_uninstall

This recipe uninstalls the Dynatrace WebServer Agent package installed by the `wsagent_package` recipe.

**Note:** this recipe does not delete the user created by the `dynatrace_user` recipe which is included by the `wsagent_package` recipe.
**Note:** as part of the uninstallation process the `opt/dynatrace` directory is deleted which is by default shared by other Dynatrace components (e.g. `agents_package`).

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

- CentOS
- Debian
- Red Hat Enterprise Linux
- Ubuntu

### Windows

- Windows 2012

## Problems? Questions? Suggestions?

This offering is [Dynatrace Community Supported](https://community.dynatrace.com/community/display/DL/Support+Levels#SupportLevels-Communitysupported/NotSupportedbyDynatrace(providedbyacommunitymember)). Feel free to share any problems, questions and suggestions with your peers on the Dynatrace Community's [Application Monitoring & UEM Forum](https://answers.dynatrace.com/spaces/146/index.html).

## License

Licensed under the MIT License. See the LICENSE file for details.
[![analytics](https://www.google-analytics.com/collect?v=1&t=pageview&_s=1&dl=https%3A%2F%2Fgithub.com%2FdynaTrace&dp=%2FDynatrace-Chef&dt=Dynatrace-Chef&_u=Dynatrace~&cid=github.com%2FdynaTrace&tid=UA-54510554-5&aip=1)]()
