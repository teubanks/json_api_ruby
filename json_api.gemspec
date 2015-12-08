# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_api/version'

Gem::Specification.new do |spec|
  spec.name          = "json_api"
  spec.version       = JSONAPI::VERSION
  spec.authors       = ["Tracey Eubanks"]
  spec.email         = ["tracey@bypassmobile.com"]
  spec.description   = %q{Create JSON API resources when you don't have Rails 4+ available}
  spec.summary       = %q{Create JSON API resources when you don't have Rails 4+ available}
  spec.homepage      = ""
  spec.license       = "BypassDon'tTouch"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rspec-its"
end
