# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flowgraph/version"

Gem::Specification.new do |spec|
  spec.name = "flowgraph"
  spec.version = Flowgraph::VERSION
  spec.summary = "Record callgraphs from your Ruby code"
  spec.description = "flowgraph instruments your ruby code so that you can inspect, record, and manipulate its call graph."
  spec.license = "MIT"

  spec.author = "Jason Gedge"
  spec.email = "jason@gedge.ca"
  spec.homepage = "https://github.com/thegedge/flowgraph"

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
  spec.add_development_dependency "simplecov"
end
