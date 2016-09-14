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
          installer = installer_for_config
          installer.prepare
          installer.install!
        end
        UI.notice "Please drag MetaModel.framework into Embedded Binaries phrase.\n"
      end

      def validate!
        super
        raise Informative, 'No Metafile in current directory' unless config.metafile_in_dir(Pathname.pwd)
      end

      private
    end
  end
end
