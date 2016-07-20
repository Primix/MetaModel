module MetaModel

  class Parser

    def initialize(scaffold_path)
      @scaffold_path = scaffold_path
      parse
    end

    def parse
      scaffolds = Dir[@scaffold_path + "*.rb"]
      scaffolds.each do |scaffold_file|
        scaffold_code = File.read(@scaffold_path + scaffold_file)
        eval scaffold_code
      end
    end

    private

    class PropertyConstructor

      def string(json_key)

      end

    end

    def metamodel_version(version)
      puts version
    end

    def define(model_name)
      model = CocoaModel.new(model_name)

      yield
    end
  end
end

module MetaModel
  class CocoaModel
    attr_reader :model_name
    attr_reader :properties

    def initialize(model_name)
      @model_name = model_name
      @properties = []
    end

    class CocoaProperty
      attr_reader :json_key
      attr_reader :property_key
      attr_reader :property_type

      def initialize(json_key, property_type, property_key = nil)
        property_key |= json_key.underscore
        @property_key = property_key
        @json_key = json_key
        @property_type = property_type
      end

    end
  end
end
