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
          { |x| x.debug_description }}" \
          if satisfy_constraint.size > 0

      end
    end
  end
end
