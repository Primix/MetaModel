require 'metamodel/version'

task default: :install

desc "Build pristine gem file with spec"
task :install do
  gem_file = "metamodel-#{MetaModel::VERSION}.gem"
  system %(gem build metamodel.gemspec)
  system %(gem install #{gem_file})
  system %(rm #{gem_file})
end
