require 'git'

module MetaModel
  class Command
    class Build < Command
      require 'metamodel/command/build/parser'
      require 'metamodel/command/build/renderer'

      self.summary = ""
      self.description = <<-DESC

      DESC

      attr_accessor :models

      def initialize(argv)
        super
      end

      def run
        UI.section "Building MetaModel project" do
          clone_project
          parse_template
          render_model_files
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

      def parse_template
        parser = Parser.new
        @models = parser.parse
      end

      def render_model_files
        title_options = { :verbose_prefix => '-> '.green }
        UI.section "Generating model files" do
          @models.each do |model|
            UI.titled_section "Using #{model.name}", title_options do
              Renderer.render(model)
            end
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
