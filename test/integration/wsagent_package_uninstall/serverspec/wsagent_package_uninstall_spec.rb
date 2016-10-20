require 'spec_helper'

if %w(debian redhat ubuntu).include? os[:family]
  describe file('/opt/dynatrace') do
    it { should_not exist }
  end

  describe file('/opt/dynatrace-6.5') do
    it { should_not exist }
  end

  describe file '/etc/init.d/dynaTraceCollector' do
    it { should_not exist }
  end

  describe process('dtwsagent') do
    it { should_not be_running }
  end

  describe service('dynaTraceWebServerAgent') do
    it { should_not be_enabled }
  end
end
