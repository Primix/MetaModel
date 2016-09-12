module MetaModel
  class Command
    class Build
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
            size = association.through ? 3 : 2
            association.through = name_model_hash[association.through]
            raise Informative, "Associations not satisfied in `Metafile`" \
              unless [association.major_model, association.secondary_model, association.through].compact.size == size
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

          @associations.each do |association|
            major_model = association.major_model
            secondary_model = association.secondary_model
            case association.relation
            when :has_one, :has_many then
              property = Record::Property.new(major_model.foreign_id, :int, :foreign, :default => 0)
              secondary_model.properties << property
            when :belongs_to then
              property = Record::Property.new(secondary_model.foreign_id, :int, :foreign, :default => 0)
              major_model.properties << property
            end
          end

          @models.each do |model|
            model.properties.uniq! { |prop| [prop.name] }
          end
        end
      end
    end
  end
end
