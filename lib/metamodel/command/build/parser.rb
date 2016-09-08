module MetaModel
  class Command
    class Build
      class Parser

        include Config::Mixin

        require 'metamodel/model/model'
        require 'metamodel/model/property'
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
          p @models
          @models
        end

        private

        def metamodel_version(version)
          raise Informative,
            "Meta file #{version} not matched with current metamodel version #{VERSION}" if version != VERSION
        end

        def define(model_name)
          @models << Model.new(model_name)
          yield
        end

        def attr(key, type = :string, *args)
          current_model.properties << Property.new(key, type, args)
        end

        def has_many(name, model)
          property = Property.new(name, model)
          raise Informative, "Property type in has_many relation can't be optional" if property.is_optional?
          current_model.relation_properties << property
        end

        def belongs_to(name, model)
          current_model.relation_properties << Property.new(name, model)
          current_model.properties << Property.new("#{name}_id".camelize, "Int", :foreign)
        end

        private

        def current_model
          @models.last
        end
      end
    end
  end
end
