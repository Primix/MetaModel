require 'git'

module MetaModel
  class Command

    class Init < Command
      self.summary = "Generate a scaffold folder for the current directory."
      self.description = <<-DESC
        Creates a scaffold folder for the current directory if none exits. Call
        this command before all other metamodel command.
      DESC

      def initialize(argv)
        @scaffold_path = Pathname.pwd + 'scaffold'
        @project_path = argv.shift_argument
        super
      end

      def validate!
        super
        raise Informative, 'Existing scaffold folder in directory' unless config.scaffold_path_in_dir(Pathname.pwd).nil?
      end

      def run
        UI.section "Initiating MetaModel project" do
          UI.section "Cloning MetaModel project into `./MetaModel` folder" do
            Git.clone(config.metamodel_template_uri, 'MetaModel')
            UI.message "Using `./MetaModel/MetaModel.xcodeproj` to build module"
          end
          UI.section "Creating `scaffold` folder for MetaModel" do
            FileUtils.mkdir(@scaffold_path)
          end
        end
      end

      private
    end
  end
end
