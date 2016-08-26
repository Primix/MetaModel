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
        @file_path = config.scaffold_path + "#{@model_name.underscore}.rb"
        super
      end

      def run
        verify_scaffold_exists!
        UI.section "Generating model scaffold file" do
          title_options = { :verbose_prefix => '-> '.green }
          UI.titled_section "Adding `#{File.basename(@file_path)}` to scaffold folder", title_options do
            @file_path.open('w') { |f| f << model_template(@model_name) }
          end
          UI.notice "`#{File.basename(@file_path)}` has already generated, use the command below to edit it.\n"
          UI.message "vim scaffold/#{File.basename(@file_path)}"
        end
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
