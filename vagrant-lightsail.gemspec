# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-lightsail/version'
require 'English'

Gem::Specification.new do |spec|
  spec.name        = 'vagrant-lightsail'
  spec.version     = VagrantPlugins::Lightsail::VERSION
  spec.authors     = ['Alejandro Figueroa']
  spec.email       = ['alejandro@ideasftw.com']
  spec.summary     = 'Enables Vagrant to manage machines in EC2 and VPC.'
  spec.description = 'Enables Vagrant to manage machines in EC2 and VPC.'
  spec.homepage    = 'http://github.com/thejandroman/vagrant-lightsail'
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'aws-sdk', '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
