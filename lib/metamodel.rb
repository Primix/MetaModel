require 'active_support/core_ext/string/strip'

module MetaModel
  require 'pathname'

  require 'metamodel/version'
  require 'metamodel/config'

  autoload :Command,   'metamodel/command'
  autoload :Exception, 'metamodel/exception'
end
