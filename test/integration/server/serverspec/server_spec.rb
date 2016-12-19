require 'json'
require 'net/http'
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

describe file('/opt/dynatrace/server') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file '/opt/dynatrace/dtserver.ini' do
  its(:content) { should match(/-memory\nsmall/) }
end

describe file '/opt/dynatrace/dtfrontendserver.ini' do
  its(:content) { should match(/-memory\nsmall/) }
end

describe file '/etc/init.d/dynaTraceServer' do
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
    its(:content) { should match(/^\# Default-Start: 2 3 4 5$/) }
    its(:content) { should match(/^\# Default-Stop: 0 1 6$/) }
  elsif os[:family] == 'redhat'
    its(:content) { should match(/^\# Default-Start: 3 5$/) }
    its(:content) { should match(/^\# Default-Stop: 0 1 2 6$/) }
  end

  its(:content) { should match(%r{^DT_HOME=/opt/dynatrace$}) }
  its(:content) { should match(/^DT_OPTARGS="-listen 6699"$/) }
  its(:content) { should match(/^DT_RUNASUSER=dynatrace$/) }
end

describe process('dtfrontendserver') do
  it { should be_running }
  its(:user) { should eq 'dynatrace' }
end

describe process('dtserver') do
  it { should be_running }
  its(:user) { should eq 'dynatrace' }
  its(:args) { should match(/-listen 6699/) }
end

describe service('dynaTraceServer') do
  it { should be_enabled }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
    it { should be_enabled.with_level(3) }
    it { should be_enabled.with_level(4) }
    it { should be_enabled.with_level(5) }
  end
end

describe port(2021) do
  it { should be_listening }
end

describe port(6699) do
  it { should be_listening }
end

describe port(6699) do
  it { should be_listening }
end

describe port(8021) do
  it { should be_listening }
end

describe port(9911) do
  it { should be_listening }
end

describe 'Dynatrace Server Performance Warehouse Configuration' do
  it 'server should respond with correct configuration' do
    uri = URI('http://localhost:8021/rest/management/pwhconnection/config')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    response = http.request(request)

    expect(response.code).to eq('200')

    data = JSON.parse(response.body)
    expect(data['pwhconnectionconfiguration']['host']).to eq('localhost')
    expect(data['pwhconnectionconfiguration']['port']).to eq('5432')
    expect(data['pwhconnectionconfiguration']['dbms']).to eq('postgresql')
    expect(data['pwhconnectionconfiguration']['dbname']).to eq('dynatrace-pwh')
    expect(data['pwhconnectionconfiguration']['user']).to eq('dynatrace')
    expect(data['pwhconnectionconfiguration']['password']).to match(/\*+/)
    expect(data['pwhconnectionconfiguration']['usessl']).to eq(false)

    # We do not check PWH connection status as the configuration is fake. Furthermore license key is required before
    # trying to enable the connection.
  end
end

describe 'Dynatrace Server LDAP Configuration' do
  it 'server should respond with correct LDAP configuration' do
    uri = URI('https://localhost:8021/api/v2/usermanagement/ldap')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    response = http.request(request)

    expect(response.code).to eq('200')

    data = JSON.parse(response.body)
    expect(data['host']).to eq('localhost')
    expect(data['port']).to eq(1234)
    expect(data['usessl']).to eq(true)
    expect(data['bindpassword']).to match(/\*+/)
    expect(data['binddn']).to eq('LDAP_Dynasprint')
    expect(data['useraccountattribute']).to eq('sAMAccountName')
    expect(data['usernameattribute']).to eq('name')
    expect(data['useremailattribute']).to eq('mail')
    expect(data['memberattribute']).to eq('memberOf')
    expect(data['groupobjectclass']).to eq('group')
    expect(data['groupdescriptionattribute']).to eq('description')

    # We do not check LDAP connection status as the configuration is fake.
  end
end

describe 'Dynatrace Server Group Configuration' do
  it 'server should respond with correct group configuration' do
    groups_uri = URI('https://localhost:8021/api/v2/usermanagement/groups')
    http = Net::HTTP.new(groups_uri.host, groups_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # 1. Get the list of all groups
    request = Net::HTTP::Get.new(groups_uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    response = http.request(request)

    expect(response.code).to eq('200')
    data = JSON.parse(response.body)
    groups = {}
    data['groups'].each { |g| groups[g['id']] = g['href'] }
    expect(groups).to have_key('group1')
    group1_details_url = groups['group1']
    expect(groups).to have_key('group2')
    group2_details_url = groups['group2']

    # 2. Get group1 details
    request = Net::HTTP::Get.new(URI(group1_details_url), 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    group1_resp = http.request(request)

    expect(group1_resp.code).to eq('200')
    group1_details = JSON.parse(group1_resp.body)
    expect(group1_details['description']).to eq('some description 1')
    expect(group1_details['managementrole']['id']).to eq('Guest')
    expect(group1_details['ldapgroup']).to eq(false)

    # 3. Get group2 details
    request = Net::HTTP::Get.new(URI(group2_details_url), 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    group2_resp = http.request(request)

    expect(group2_resp.code).to eq('200')
    group2_details = JSON.parse(group2_resp.body)
    expect(group2_details['description']).to eq('some description 2')
    expect(group2_details['managementrole']['id']).to eq('Administrator')
    expect(group2_details['ldapgroup']).to eq(true)
  end
end

describe 'Dynatrace Server User Configuration' do
  it 'server should respond with correct user configuration' do
    user_uri = URI('https://localhost:8021/api/v2/usermanagement/users/newuserid')
    http = Net::HTTP.new(user_uri.host, user_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(user_uri, 'Accept' => 'application/json', 'Content-Type' => 'application/json')
    request.basic_auth('admin', 'admin')
    response = http.request(request)

    expect(response.code).to eq('200')
    data = JSON.parse(response.body)

    expect(data['userid']).to eq('newuserid')
    expect(data['fullname']).to eq('New User')
    expect(data['email']).to eq('new@user.com')
    # NOTE: The 'ldapuser' property cannot be validated
  end
end
