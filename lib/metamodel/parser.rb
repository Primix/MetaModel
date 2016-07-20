module MetaModel

  class Parser

    require 'metamodel/model/cocoa_model'
    require 'metamodel/model/cocoa_property'
    require 'metamodel/model/property_constructor'

    def initialize(scaffold_path)
      @scaffold_path = scaffold_path
      @models = []
      parse
      puts @models
    end

    def parse
      scaffolds = Dir[@scaffold_path + "*.rb"]
      scaffolds.each do |scaffold_file|
        scaffold_code = File.read(@scaffold_path + scaffold_file)
        eval scaffold_code
      end
    end

    private

    def metamodel_version(version)
      raise Informative,
        "Scaffold file #{version} not matched with current metamodel version #{VERSION}" if version != VERSION
      puts version
    end

    def define(model_name)
      model = CocoaModel.new(model_name)

      yield PropertyConstructor.new(model)

      @models << model
    end

  end
end
