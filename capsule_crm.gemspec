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

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_runtime_dependency('activemodel')
  gem.add_runtime_dependency('activesupport')
  gem.add_runtime_dependency('faraday')
  gem.add_runtime_dependency('faraday_middleware')
  gem.add_runtime_dependency('virtus', '~> 0.5.4')

  gem.add_development_dependency('coveralls')
  gem.add_development_dependency('cucumber')
  gem.add_development_dependency('fabrication')
  gem.add_development_dependency('faker')
  gem.add_development_dependency('guard')
  gem.add_development_dependency('guard-bundler')
  gem.add_development_dependency('guard-rspec')
  gem.add_development_dependency('rb-fsevent')
  gem.add_development_dependency('rspec', '~> 2.14.0')
  gem.add_development_dependency('shoulda-matchers')
  gem.add_development_dependency('webmock')
end
