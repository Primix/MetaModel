require 'git'

module MetaModel
  class Command
    class Install < Command
      include Config::Mixin
      self.summary = "Build a MetaModel.framework from Metafile"
      self.description = <<-DESC
        Clone a metamodel project template from GitHub, parsing Metafile, validating models,
        generate model swift file and build MetaModel.framework.
      DESC

      attr_accessor :models

      def initialize(argv)
        validate!
        super
      end

      def run
        UI.section "Building MetaModel.framework in project" do
          prepare
          installer = installer_for_config
          installer.install!
        end
        UI.notice "Please drag MetaModel.framework into Embedded Binaries phrase.\n"
      end

      def prepare
        clone_project
      end

      def clone_project
        if File.exist? config.metamodel_xcode_project
          UI.message "Existing project `#{config.metamodel_xcode_project}`"
        else
          UI.section "Cloning MetaModel project into `./metamodel` folder" do
            Git.clone(config.metamodel_template_uri, 'metamodel', :depth => 1)
            UI.message "Using `#{config.metamodel_xcode_project}` to build module"
          end
        end
      end

      def validate!
        # super
        raise Informative, 'No Metafile in current directory' unless config.metafile_in_dir(Pathname.pwd)
      end

      private
    end
  end
end
