require 'pathname'
require 'active_support/core_ext/string/strip'

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
        @file_path = Pathname.pwd + "#{@model_name.downcase}.rb"
        super
      end

      def run
        @file_path.open('w') { |f| f << model_template(@model_name) }
      end

      private

      def model_template(model)
        modelfile = ''
        modelfile << "metamodel_version '#{VERSION}'\n\n"
        modelfile << <<-MODEL.strip_heredoc
          define :#{model} do |j|
            # define #{model} model like this
            # j.string 'nickname'
          end
        MODEL
      end

    end
  end
end
