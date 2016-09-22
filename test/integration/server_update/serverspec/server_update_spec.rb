require 'net/http'
require 'rexml/document'
include REXML
require 'serverspec'

# Required by serverspec
set :backend, :exec

describe 'Dynatrace Server update' do
  it 'server should respond with correct version' do
    uri = URI('https://localhost:8021/rest/management/version')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri, 'Accept' => 'text/xml')
    request.basic_auth('admin', 'admin')
    response = http.request(request)
    expect(response.code).to eq('200')

    # e.g. <?xml version="1.0" encoding="UTF-8" standalone="yes"?><result value="6.3.10.1010"/>
    xmldoc = Document.new(response.body)
    result = XPath.first(xmldoc, '//result')
    version = result.attributes['value']
    expect(version).to eq('6.3.10.1010')
  end
end
