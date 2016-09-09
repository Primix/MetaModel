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
        @metafile_path = config.metafile_path
        super
      end

      def run
        verify_meta_exists!
        UI.section "Generating model meta file" do
          title_options = { :verbose_prefix => '-> '.green }
          UI.titled_section "Adding `#{@model_name.camelize} model to Metafile", title_options do
            p @metafile_path
            @metafile_path.open('a') do |source|
              source.puts model_template(@model_name)
            end
          end
          UI.notice "Adding `#{@model_name.camelize}` has already generated, use the command below to edit it.\n"
          UI.message "vim Metafile"
        end
      end

      private

      def model_template(model)
        <<-TEMPLATE.strip_heredoc

          define :#{model} do
            # define #{model} model like this
            # attr nickname, :string
          end
        TEMPLATE
      end
    end
  end
end
