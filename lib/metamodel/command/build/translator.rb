module MetaModel
  class Command
    class Install
      class Translator
        require 'metamodel/record/model'
        require 'metamodel/record/property'
        require 'metamodel/record/association'

        attr_reader :models
        attr_reader :associations

        def initialize(models, associations)
          @models = models
          @associations = associations
        end

        def translate
          name_model_hash = Hash[@models.collect { |model| [model.name, model] }]
          @associations.map! do |association|
            major_model = name_model_hash[association.major_model]
            major_model.associations << association
            association.major_model = major_model
            association.secondary_model = name_model_hash[association.secondary_model]
            raise Informative, "Associations not satisfied in `Metafile`" \
              unless [association.major_model, association.secondary_model].compact.size == 2
            association
          end

          satisfy_constraint = @associations.reduce([]) do |remain, association|
            expect = remain.select { |assoc| assoc.expect_constraint? association }
            if expect.empty?
              remain << association
            else
              remain.delete expect.first
            end
            remain
          end
          raise Informative, "Unsatisfied constraints in #{satisfy_constraint.map \
            { |x| x.debug_description }}" \
            if satisfy_constraint.size > 0

          @models.each do |model|
            model.properties.uniq! { |prop| [prop.name] }
          end
          return @models, @associations
        end
      end
    end
  end
end
