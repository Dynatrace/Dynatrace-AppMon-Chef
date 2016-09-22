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

describe file('/opt/dynatrace/agent') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file '/opt/dynatrace/agent/conf/dthostagent.ini' do
  its(:content) { should match /^Name myhostagent/ }
  its(:content) { should match /^Server myhostaddr/ }
end

describe file '/etc/init.d/dynaTraceHostagent' do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe service('dynaTraceHostagent') do
  it { should be_enabled }
end

describe process('dthostagent') do
  it { should be_running }
end
