source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 7.0']
end

gem 'rake'
gem 'librarian-puppet'
gem 'puppet',  puppetversion
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
