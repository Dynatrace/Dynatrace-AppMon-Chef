source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'java'

group :integration do
  cookbook 'apache2'
  cookbook 'dynatrace_pwh_postgresql', path: 'test/fixtures/cookbooks/dynatrace_pwh_postgresql'
end

