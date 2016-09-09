require_relative 'lib/metamodel/version'

require "pathname"

task :default => [:build, :install, :clean]

task :release => [:build, :push, :clean]

task :push do
  system %(gem push #{build_product_file})
end

task :build do
  system %(gem build metamodel.gemspec)
end

task :install do
  system %(gem install #{build_product_file})
end

task :clean do
  system %(rm *.gem)
end

def build_product_file
  "metamodel-#{MetaModel::VERSION}.gem"
end
