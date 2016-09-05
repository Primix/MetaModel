module MetaModel
  class Command

    class Init < Command
      self.summary = "Generate a meta folder for the current directory."
      self.description = <<-DESC
        Creates a meta folder for the current directory if none exits. Call
        this command before all other metamodel command.
      DESC

      def initialize(argv)
        @meta_path = Pathname.pwd + 'meta'
        @project_path = argv.shift_argument
        super
      end

      def validate!
        super
        raise Informative, 'Existing meta folder in directory' unless config.meta_path_in_dir(Pathname.pwd).nil?
      end

      def run
        UI.section "Initialing MetaModel project" do
          UI.section "Creating `meta` folder for MetaModel" do
            FileUtils.mkdir(@meta_path)
          end
        end
      end

      private
    end
  end
end
