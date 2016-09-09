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
          UI.section "Analyzing Metafile" do
            metafile_path = config.metafile_path
            eval File.read(metafile_path)
          end
          @models
        end

        private

        def metamodel_version(version)
          raise Informative,
            "Meta file #{version} not matched with current metamodel version #{VERSION}" if version != VERSION
        end

        def define(model_name)
          UI.message '-> '.green + "Resolving `#{model_name.to_s.camelize}`"
          @models << Model.new(model_name)
          yield
        end

        def attr(key, type = :string, *args)
          current_model.properties << Property.new(key, type, args)
        end

        def has_one(name, model = nil)
          model = name.to_s.singularize.camelize if model.nil?
          current_model.relation_properties << Property.new(name, model, :has_one)
        end

        def has_many(name, model = nil)
          model = name.to_s.singularize.camelize if model.nil?
          property = Property.new(name, model, :has_many)
          raise Informative, "Property type in has_many relation can't be optional" if property.is_optional?
          current_model.relation_properties << property
        end

        def belongs_to(name, model = nil)
          model = name.to_s.singularize.camelize if model.nil?
          current_model.relation_properties << Property.new(name, model, :belongs_to)
          current_model.properties << Property.new("#{name}_id".camelize, "Int", :foreign, :default => 0)
        end

        private

        def current_model
          @models.last
        end
      end
    end
  end
end
