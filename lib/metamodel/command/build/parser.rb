module MetaModel
  class Command
    class Build
      class Parser

        include Config::Mixin

        require 'metamodel/model/cocoa_model'
        require 'metamodel/model/cocoa_property'
        require 'metamodel/model/property_constructor'
        require 'metamodel/command/build/renderer'

        def initialize
          @models = []
        end

        def parse
          UI.section "Analyzing scaffold files" do
            scaffold_path = config.scaffold_path
            scaffolds = Dir[scaffold_path + "*.rb"]
            scaffolds.each do |scaffold_file|
              UI.message '-> '.green + "Resolving `#{File.basename(scaffold_file)}`"
              scaffold_code = File.read(scaffold_path + scaffold_file)
              eval scaffold_code
            end
          end
          @models
        end

        private

        def metamodel_version(version)
          raise Informative,
            "Scaffold file #{version} not matched with current metamodel version #{VERSION}" if version != VERSION
        end

        def define(model_name)
          model = CocoaModel.new(model_name)
          yield PropertyConstructor.new(model)
          @models << model
        end
      end
    end
  end
end
