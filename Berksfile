source 'https://supermarket.chef.io'

metadata

cookbook 'apt'
cookbook 'java'
cookbook 'line'

group :integration do
  cookbook 'apache2'
end

# Need this for cc12.x testing
cookbook 'windows', '~> 3.0.4'
cookbook 'apache2', '~> 6.0.0'
