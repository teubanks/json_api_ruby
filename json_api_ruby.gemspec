# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json_api_ruby/version'

Gem::Specification.new do |spec|
  spec.name          = "json_api_ruby"
  spec.version       = JsonApi::VERSION
  spec.authors       = ["Tracey Eubanks"]
  spec.email         = ["tracey@bypassmobile.com"]
  spec.description   = %q{Extremely lightweight implementation of JSON API}
  spec.summary       = %q{Extremely lightweight implementation of JSON API}
  spec.homepage      = "https://github.com/teubanks/jsonapi_ruby"
  spec.license       = "Free For All"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 3"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "rspec-its", "~> 1"
  spec.add_development_dependency "pry-byebug", "~> 3"
  spec.add_development_dependency "guard-rspec", "~> 4"
end
