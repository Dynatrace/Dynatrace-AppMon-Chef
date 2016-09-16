require 'spec_helper'

if ['debian', 'redhat', 'ubuntu'].include? os[:family]
  describe file('/opt/dynatrace') do
    it { should_not exist }
  end
end
