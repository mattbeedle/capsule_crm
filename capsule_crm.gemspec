# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capsule_crm/version'

Gem::Specification.new do |gem|
  gem.name          = "capsule_crm"
  gem.version       = CapsuleCrm::VERSION
  gem.authors       = ["Matt Beedle"]
  gem.email         = ["mattbeedle@googlemail.com"]
  gem.description   = %q{Gem to communicate with CapsuleCRM}
  gem.summary       = %q{Gem to communicate with CapsuleCRM}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('activemodel')
  gem.add_runtime_dependency('activesupport')
  gem.add_runtime_dependency('faraday')
  gem.add_runtime_dependency('faraday_middleware')
  gem.add_runtime_dependency('virtus')

  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('rb-fsevent')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('shoulda-matchers')
  gem.add_development_dependency('webmock')
end
