require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file('/opt/dynatrace') do
  it { should_not exist }
end

describe file('/opt/dynatrace-6.5') do
  it { should_not exist }
end

describe file '/etc/init.d/dynaTraceHostagent' do
  it { should_not exist }
end

describe process('dthostagent') do
  it { should_not be_running }
end
