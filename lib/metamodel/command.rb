require 'colored'
require 'claide'

module MetaModel
  class Command < CLAide::Command
    require 'metamodel/command/init'
    require 'metamodel/command/generate'
    require 'metamodel/command/build'
    require 'metamodel/command/clean'

    include Config::Mixin

    self.abstract_command = true
    self.command = 'meta'
    self.version = VERSION
    self.description = 'MetaModel, the Model generator.'
    self.plugin_prefixes = %w(claide meta)

    METAMODEL_COMMAND_ALIAS = {
      "g"  => "generate",
      "i"  => "init",
      "b"  => "build",
      "c"  => "clean"
    }

    def self.run(argv)
      if METAMODEL_COMMAND_ALIAS[argv.first]
        super([METAMODEL_COMMAND_ALIAS[argv.first]] + argv[1..-1])
      else
        super(argv)
      end
    end

    def initialize(argv)
      super
      # config.verbose = self.verbose?
      config.verbose = true
    end

    #-------------------------------------------------------------------------#

    private

    # Checks that meta folder exists
    #
    # @return [void]
    def verify_meta_exists!
      unless config.metefile_exist?
        raise Informative, "No `meta' folder found in the project directory."
      end
    end
  end
end
