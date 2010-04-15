lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/response_signature'

Gem::Specification.new do |s|
  s.name          = 'rack-response-signature'
  s.version       = Rack::ResponseSignature::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ['Nathaniel Bibler']
  s.email         = 'gem@nathanielbibler.com'
  s.homepage      = 'http://github.com/nbibler/rack_response_signature'
  s.summary       = 'Rack middleware to add transparent response signing'
  s.description   = 'Rack::ResponseSignature uses RSA key pairs to transparently sign the outgoing responses from any Rack-compliant application.'
  
  s.files         = Dir.glob("lib/**/*") + %w(README.rdoc)
  s.require_path  = 'lib'
end