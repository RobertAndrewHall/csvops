# frozen_string_literal: true

require_relative "lib/csvtool/version"

Gem::Specification.new do |spec|
  spec.name = "csvops"
  spec.version = Csvtool::VERSION
  spec.authors = ["Robert Hall"]
  spec.email = [""]

  spec.summary = "Interactive CSV column extraction CLI"
  spec.description = "A small Ruby CLI for extracting CSV columns interactively or via direct command."
  spec.homepage = "https://github.com/RobertAndrewHall/csvops"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.files = Dir.glob("{lib,exe,bin,test,docs}/**/*") + %w[README.md Gemfile Rakefile csvops.gemspec]
  spec.bindir = "exe"
  spec.executables = ["csvtool"]
  spec.require_paths = ["lib"]

  spec.add_dependency "csv"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
