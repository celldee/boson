# -*- encoding: utf-8 -*-
require 'rubygems' unless Object.const_defined?(:Gem)
require File.dirname(__FILE__) + "/lib/boson/version"

Gem::Specification.new do |s|
  s.name        = "boson"
  s.version     = Boson::VERSION
  s.authors     = ["Gabriel Horner"]
  s.email       = "gabriel.horner@gmail.com"
  s.homepage    = "http://tagaholic.me/boson/"
  s.summary = "A command/task framework similar to rake and thor that opens your ruby universe to the commandline and irb."
  s.description =  "Boson is a modular command/task framework. Thanks to its rich set of plugins, it differentiates itself from rake and thor by being usable from irb and the commandline, having optional automated views generated by hirb and allowing libraries to be written as plain ruby. Works with ruby >= 1.9.2"
  s.required_rubygems_version = ">= 1.3.6"
  s.executables = ['boson']
  s.add_development_dependency 'mocha', '~> 0.10.4'
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'mocha-on-bacon'
  s.add_development_dependency 'bacon-bits'
  s.add_development_dependency 'bahia', '>= 0.5.0'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc,md} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec .travis.yml}
  s.files += ['.rspec']
  s.extra_rdoc_files = ["README.md", "LICENSE.txt", "Upgrading.md"]
  s.license = 'MIT'
end
