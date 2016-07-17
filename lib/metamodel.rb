require 'active_support/core_ext/string/strip'

module MetaModel
  require 'pathname'

  require 'metamodel/version'
  require 'metamodel/config'

  # Indicates an user error. This is defined in cocoapods-core.
  #
  # class Informative < PlainInformative
  #   def message
  #     "[!] #{super}".red
  #   end
  # end

  autoload :Command, 'metamodel/command'
end
