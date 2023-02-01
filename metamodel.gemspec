# encoding: UTF-8
require File.expand_path('../lib/metamodel/version', __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name     = "metamodel"
  s.version  = MetaModel::VERSION
  s.date     = Date.today
  s.license  = "MIT"
  s.email    = ["stark.draven@gmail.com"]
  s.homepage = "https://github.com/MModel/MetaModel"
  s.authors  = ["Draveness Zuo"]

  s.summary     = "The Cocoa models generator."
  s.description = "Automatically generate model layout for iOS project."

  s.files = Dir["lib/**/*.rb"] + %w{ bin/meta README.md LICENSE } + Dir["lib/**/*.swift"]

  s.executables = %w{ meta }
  s.require_paths = %w{ lib }

  s.add_runtime_dependency 'claide',         '>= 1.0.0', '< 2.0'
  s.add_runtime_dependency 'colored',        '~> 1.2'
  s.add_runtime_dependency 'xcodeproj',      '~> 1.2'
  s.add_runtime_dependency 'activesupport',  '>= 4.2.6', '< 8.0'
  s.add_runtime_dependency "mustache",       "~> 1.0"
  s.add_runtime_dependency "git",            "~> 1.3"

  s.add_development_dependency 'bundler',   '~> 1.3'
  s.add_development_dependency 'rake',      '~> 10.0'

end
