require 'serverspec'

# Required by serverspec
set :backend, :exec

if os[:family] == 'debian' || os[:family] == 'ubuntu'
  describe file '/etc/apache2/apache2.conf' do
    its(:content) { should_not match /^LoadModule dtagent_module/ }
  end
elsif os[:family] == 'redhat'
  describe file '/etc/httpd/conf/httpd.conf' do
    its(:content) { should_not match /^LoadModule dtagent_module/ }
  end
end
