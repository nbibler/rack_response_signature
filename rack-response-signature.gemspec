# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/response_signature'

Gem::Specification.new do |spec|
  spec.name          = 'rack-response-signature'
  spec.version       = Rack::ResponseSignature::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Nathaniel Bibler']
  spec.email         = ['gem@nathanielbibler.com']
  spec.description   = 'Rack::ResponseSignature uses RSA key pairs to transparently sign the outgoing responses from any Rack-compliant application.'
  spec.summary       = 'Rack middleware to add transparent response signing'
  spec.homepage      = 'http://github.com/nbibler/rack_response_signature'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rack', '~> 1.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler', '~> 1.3'
end
