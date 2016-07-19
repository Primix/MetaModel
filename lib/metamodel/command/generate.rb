module MetaModel
  class Command
    class Generate < Command

      self.summary = "Generate a class skeleton for a model."
      self.description = <<-DESC
        Generate a skeleton for a Objective-C/Swift class and create
        this file as model.rb in MetaModel folder.
      DESC

      def initialize(argv)
        @model_name = argv.shift_argument
        @file_path = config.scaffold_path + "#{@model_name.downcase}.rb"
        super
      end

      def run
        verify_scaffold_exists!
        @file_path.open('w') { |f| f << model_template(@model_name) }
      end

      private

      def model_template(model)
        modelfile = ''
        modelfile << "metamodel_version '#{VERSION}'\n\n"
        modelfile << <<-TEMPLATE.strip_heredoc
          define :#{model} do |j|
            # define #{model} model like this
            # j.string 'nickname'
          end
        TEMPLATE
        modelfile
      end
    end
  end
end
