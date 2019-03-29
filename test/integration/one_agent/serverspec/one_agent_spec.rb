# frozen_string_literal: true

require 'spec_helper'

if %w[debian redhat ubuntu].include? os[:family]
  describe user('dynatrace') do
    it { should exist }
    it { should belong_to_group 'dynatrace' }
  end

  describe file('/opt/dynatrace-oneagent') do
    it { should be_directory }
    it { should be_symlink }
  end

  describe file('/opt/dynatrace-oneagent/agent') do
    it { should be_directory }
    it { should be_owned_by 'dynatrace' }
    it { should be_grouped_into 'dynatrace' }
  end
elsif os[:family] == 'windows'
  describe file('C:\Program Files (x86)\Dynatrace') do
    it { should be_directory }
  end

  describe file('C:\Program Files (x86)\Dynatrace\agent') do
    it { should be_directory }
  end
end
