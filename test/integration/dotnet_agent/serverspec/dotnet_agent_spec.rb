# frozen_string_literal: true

require 'spec_helper'

describe windows_registry_key('HKLM:\SOFTWARE\Wow6432Node\dynaTrace\Agent\Whitelist\1') do
  it { should exist }
  it { should have_property_value('active',  :type_string, 'TRUE') }
  it { should have_property_value('path',    :type_string, '*') }
  it { should have_property_value('name',    :type_string, 'dotnetagent') }
  it { should have_property_value('exec',    :type_string, 'w3wp.exe') }
  it { should have_property_value('cmdline', :type_string, '-ap myApp') }
end
