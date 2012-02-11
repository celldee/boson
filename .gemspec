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
  s.description =  "Boson is a command/task framework with the power to turn any ruby method into a full-fledged executable with options.  Some unique features that differentiate it from rake and thor include being usable from irb and the commandline, optional automated views generated by hirb and allowing libraries to be written as plain ruby. For my libraries that use this, see irbfiles.  Works with all major ruby versions."
  s.required_rubygems_version = ">= 1.3.6"
  s.executables = ['boson']
  s.add_dependency 'hirb', '>= 0.5.0'
  s.add_dependency 'alias', '>= 0.2.2'
  s.add_development_dependency 'mocha', '= 0.9.8'
  s.add_development_dependency 'bacon', '>= 1.1.0'
  s.add_development_dependency 'mocha-on-bacon'
  s.add_development_dependency 'bacon-bits'
  s.add_development_dependency, 'rake'
  s.files = Dir.glob(%w[{lib,test}/**/*.rb bin/* [A-Z]*.{txt,rdoc} ext/**/*.{rb,c} **/deps.rip]) + %w{Rakefile .gemspec}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE.txt"]
  s.license = 'MIT'
end
