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
          update_initialize_method
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
        UI.section "Generating model files" do
          Renderer.render(@models)
        end
      end

      def update_initialize_method
        template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/metamodel.swift.erb"))
        result = ErbalT::render_from_hash(template, { :models => @models })
        model_path = Pathname.new("./MetaModel/MetaModel/MetaModel.swift")
        File.write model_path, result
      end

      def validate!
        super
        raise Informative, 'No meta folder in directory' unless config.meta_path_in_dir(Pathname.pwd)
      end

      private

      class ErbalT < OpenStruct
        def self.render_from_hash(t, h)
          ErbalT.new(h).render(t)
        end

        def render(template)
          ERB.new(template).result(binding)
        end
      end

    end
  end
end
