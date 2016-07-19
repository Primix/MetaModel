require 'active_support/core_ext/string/strip'

module MetaModel

  class PlainInformative < StandardError; end

  # Indicates an user error. This is defined in cocoapods-core.
  #
  class Informative < PlainInformative
    def message
      "[!] #{super}".red
    end
  end

  require 'pathname'

  require 'metamodel/version'
  require 'metamodel/config'

  autoload :Command,   'metamodel/command'
end
