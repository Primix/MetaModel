# encoding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metamodel/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = "metamodel"
  s.version  = MetaModel::VERSION
  s.date     = Date.today
  s.license  = "MIT"
  s.email    = ["stark.draven@gmail.com"]
  s.homepage = "https://github.com/Draveness/MetaModel"
  s.authors  = ["Draveness Zuo"]

  s.summary     = "The Cocoa models generator."
  s.description = "Not desc for now."

  s.files = Dir["lib/**/*.rb"]
end

