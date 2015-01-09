# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "es-reindex/version"

Gem::Specification.new do |s|
  s.name        = "es-reindex"
  s.version     = ESReindex::VERSION
  s.authors     = ["Justin Aiken"]
  s.email       = ["jaiken@mojolingo.com"]
  s.homepage    = "https://github.com/mojolingo/es-reindex"
  s.summary     = %q{Ruby gem to copy ElasticSearch index (reindex).}
  s.description = %q{Ruby gem to copy ElasticSearch index (reindex).}
  s.license     = 'MIT'

  s.rubyforge_project = "es-reindex"

  s.required_ruby_version = '>= 1.9.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rest-client', '>= 1.6.0'
  s.add_runtime_dependency 'multi_json'

  s.add_development_dependency %q<coveralls>, ['>= 0']
  s.add_development_dependency %q<bundler>, ["~> 1.0"]
  s.add_development_dependency %q<rspec>, ["~> 2.99"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>, ['~> 4.5']
 end
