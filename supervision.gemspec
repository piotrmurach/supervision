# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'supervision/version'

Gem::Specification.new do |spec|
  spec.name          = "supervision"
  spec.version       = Supervision::VERSION
  spec.authors       = ["Piotr Murach"]
  spec.email         = [""]
  spec.summary       = %q{Write distributed systems that are resilient and self-heal.}
  spec.description   = %q{Write distributed systems that are resilient and self-heal. Remote calls can fail or hang indefinietly without a response. Supervision will help to isolate failure and keep individual components from bringing down the whole system.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "finite_machine", "~> 0.6.1"
  spec.add_development_dependency "bundler", "~> 1.6"
end
