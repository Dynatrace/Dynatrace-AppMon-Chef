require 'serverspec'

# Required by serverspec
set :backend, :exec

describe user('dynatrace') do
  it { should exist }
  it { should belong_to_group 'dynatrace' }
end

describe file('/opt/dynatrace') do
  it { should be_directory }
  it { should be_symlink }
end

describe file('/opt/dynatrace/collector') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file ('/etc/init.d/dynaTraceCollector') do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
    its(:content) { should match /^\# Default-Start: 2 3 4 5$/ }
    its(:content) { should match /^\# Default-Stop: 0 1 6$/ }
  elsif os[:family] == 'redhat'
    its(:content) { should match /^\# Default-Start: 3 5$/ }
    its(:content) { should match /^\# Default-Stop: 0 1 2 6$/ }
  end

  its(:content) { should match /^DT_HOME=\/opt\/dynatrace$/ }
  its(:content) { should match /^DT_OPTARGS="-listen 9998 -server localhost:6698 -Xms256M -Xmx1024M -XX:PermSize=256m -XX:MaxPermSize=384m"$/ }
  its(:content) { should match /^.*su - dynatrace -c.*$/ }
end

describe process('dtcollector') do
  it { should be_running }
  its(:user) { should eq 'dynatrace' }
  its(:args) { should match /-listen 9998/ }
  its(:args) { should match /-Xms256M/ }
  its(:args) { should match /-Xmx1024M/ }
  its(:args) { should match /-XX:PermSize=256m/ }
  its(:args) { should match /-XX:MaxPermSize=384m/ }
end

describe service('dynaTraceCollector') do
  it { should be_enabled }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end

describe port(9998) do
  it { should be_listening }
end
