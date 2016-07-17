require 'colored'
require 'claide'

module MetaModel
  class PlainInformative
    include CLAide::InformativeError
  end

  class Command < CLAide::Command
    require 'metamodel/command/init'
    require 'metamodel/command/generate'
    require 'metamodel/command/build'

    self.abstract_command = true
    self.command = 'mm'
    self.version = VERSION
    self.description = 'MetaModel, the Model generator.'
    self.plugin_prefixes = %w(claide mm)

    def self.run(argv)
      super(argv)
    end

    #-------------------------------------------------------------------------#

    include Config::Mixin

    private

    def verify_scaffold_exists!
      unless config.scaffold_folder
        raise Informative, "No `scaffold' folder found in the project directory."
      end
    end
  end
end
