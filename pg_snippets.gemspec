# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_snippets/version'

Gem::Specification.new do |spec|
  spec.name          = "pg_snippets"
  spec.version       = PgSnippets::VERSION
  spec.authors       = ["Tyler Hartland"]
  spec.email         = ["tylerhartland7@gmail.com"]

  spec.summary       = 'A collection of Postgres data definition SQL builders'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pg"
end
