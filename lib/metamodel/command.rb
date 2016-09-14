require 'colored'
require 'claide'

module MetaModel
  class Command < CLAide::Command
    require 'metamodel/command/init'
    require 'metamodel/command/generate'
    require 'metamodel/command/install'
    require 'metamodel/command/clean'

    include Config::Mixin

    self.abstract_command = true
    self.command = 'meta'
    self.version = VERSION
    self.description = 'MetaModel, the Model generator.'
    self.plugin_prefixes = %w(claide meta)

    METAMODEL_COMMAND_ALIAS = {
      "g"  => "generate",
      "i"  => "install",
      "b"  => "build",
      "c"  => "clean"
    }

    METAMODEL_OPTION_ALIAS = {
      "-s"  => "--skip-build"
    }

    def self.run(argv)
      if METAMODEL_COMMAND_ALIAS[argv.first]
        super([METAMODEL_COMMAND_ALIAS[argv.first]] + argv[1..-1])
      else
        super(argv)
      end
    end

    def self.options
      [
        ['--skip-build', 'Skip building MetaModel framework process']
      ].concat(super)
    end

    def initialize(argv)
      config.skip_build = argv.flag?("skip-build", false)
      # config.verbose = self.verbose?
      config.verbose = true
      super
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
