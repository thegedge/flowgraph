# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "callgraph/version"

Gem::Specification.new do |spec|
  spec.name = "callgraph"
  spec.version = Callgraph::VERSION
  spec.authors = ["Jason Gedge"]
  spec.email = ["jason@gedge.ca"]

  spec.summary = "Generate a ruby callgraph database"
  spec.description = "Profile a piece of code and generate a call graph from it"
  spec.homepage = "https://gedge.ca"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3", "~> 1.3"

  spec.add_development_dependency "bundler", "~> 1.16.a"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "minitest", "~> 5.11"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "byebug"
end
