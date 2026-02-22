# frozen_string_literal: true

require_relative "lib/csvtool/version"

Gem::Specification.new do |spec|
  spec.name = "csvops"
  spec.version = Csvtool::VERSION
  spec.authors = ["Robert Hall"]
  spec.email = [""]

  spec.summary = "Ruby CLI for practical CSV data workflows"
  spec.description = "A Ruby CLI for guided CSV workflows and direct commands including extraction, randomization, splitting, parity checks, deduplication, and stats."
  spec.homepage = "https://github.com/RobertAndrewHall/csvops"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir.glob("{lib,exe,bin,test,docs}/**/*") + %w[README.md Gemfile Rakefile csvops.gemspec]
  spec.bindir = "exe"
  spec.executables = ["csvtool"]
  spec.require_paths = ["lib"]

  spec.add_dependency "csv", "~> 3.3"
  spec.add_development_dependency "minitest", "~> 6.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
