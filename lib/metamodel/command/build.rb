require 'git'

module MetaModel
  class Command
    class Build < Command
      self.summary = ""
      self.description = <<-DESC

      DESC

      def initialize(argv)
        super
      end

      def run
        UI.section "Building MetaModel project" do
          clone_project
          Parser.new(config.scaffold_path)
        end
      end

      def clone_project
        if File.exist? config.metamodel_xcode_project
          UI.message "Existing project `#{config.metamodel_xcode_project}`"
        else
          UI.section "Cloning MetaModel project into `./MetaModel` folder" do
            Git.clone(config.metamodel_template_uri, 'MetaModel')
            UI.message "Using `./MetaModel/MetaModel.xcodeproj` to build module"
          end
        end
      end

      def validate!
        super
        raise Informative, 'No scaffold folder in directory' unless config.scaffold_path_in_dir(Pathname.pwd)
      end

      private
    end
  end
end
