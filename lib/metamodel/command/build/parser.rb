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
          UI.section "Analyzing meta files" do
            meta_path = config.meta_path
            metas = Dir[meta_path + "*.rb"]
            metas.each do |meta_file|
              UI.message '-> '.green + "Resolving `#{File.basename(meta_file)}`"
              meta_code = File.read(meta_path + meta_file)
              eval meta_code
            end
          end
          @models
        end

        private

        def metamodel_version(version)
          raise Informative,
            "Meta file #{version} not matched with current metamodel version #{VERSION}" if version != VERSION
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
