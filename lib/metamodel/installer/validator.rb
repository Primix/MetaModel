module MetaModel
  class Installer
    class Validator
      require 'metamodel/record/model'
      require 'metamodel/record/property'
      require 'metamodel/record/association'

      def translate!
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
          { |x| x.debug_description }}" if satisfy_constraint.size > 0

      end

      def validate_models
        existing_types = @models.map { |m| m.properties.map { |property| property.type } }.flatten.uniq
        unsupported_types = existing_types - supported_types
        raise Informative, "Unsupported types #{unsupported_types}" unless unsupported_types == []
      end

      CURRENT_SUPPORTED_BUILT_IN_TYPES = %w[
        Int
        Double
        Float
        String
        Bool
        NSDate
      ]

      def built_in_types
        CURRENT_SUPPORTED_BUILT_IN_TYPES.map do |t|
          [t, "#{t}?"]
        end.flatten
      end

      def supported_types
        @models.reduce(CURRENT_SUPPORTED_BUILT_IN_TYPES) { |types, model|
          types << model.name.to_s
        }.map { |type|
          [type, "#{type}?"]
        }.flatten
      end


    end
  end
end
