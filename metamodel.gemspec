# encoding: UTF-8
require 'date'

Gem::Specification.new do |s|
  s.name     = "metamodel"
  s.version  = '0.0.1'
  s.date     = Date.today
  s.license  = "MIT"
  s.email    = ["stark.draven@gmail.com"]
  s.homepage = "https://github.com/Draveness/MetaModel"
  s.authors  = ["Draveness Zuo"]

  s.summary     = "The Cocoa models generator."
  s.description = "Not desc for now."

  s.files = Dir["lib/**/*.rb"]
end

