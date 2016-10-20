require 'spec_helper'

if %w(debian redhat ubuntu).include? os[:family]
  describe file('/opt/dynatrace') do
    it { should_not exist }
  end

  describe file('/opt/dynatrace-6.5') do
    it { should_not exist }
  end
end
