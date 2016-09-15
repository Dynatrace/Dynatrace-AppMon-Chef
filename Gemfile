source 'https://rubygems.org'

group :integration do
  # Workaround: berkshell is dependent on buff-extensions gem but install older version as the new one (2.0.0) requires 
  # ruby 2.2 and chefdk up to 0.17 provides ruby 2.1.8
  gem 'buff-extensions', '~>1.0.0' 
  gem 'berkshelf'
  gem 'kitchen-docker', '>=2.3.0'
  gem 'kitchen-vagrant', '>=0.18.0'
  gem 'test-kitchen', '>=1.4.2'
  gem 'winrm-transport', '>=1.0.2'
end
