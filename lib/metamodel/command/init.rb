module MetaModel
  class Command

    class Init < Command
      self.summary = "Generate a meta folder for the current directory."
      self.description = <<-DESC
        Creates a meta folder for the current directory if none exits. Call
        this command before all other metamodel command.
      DESC

      def initialize(argv)
        @metafile_path = Pathname.pwd + 'Metafile'
        @project_path = argv.shift_argument
        super
      end

      def validate!
        super
        raise Informative, 'Existing Metafile in directory' unless config.metafile_in_dir(Pathname.pwd).nil?
      end

      def run
        UI.section "Initialing MetaModel project" do
          UI.section "Creating `Metafile` for MetaModel" do
            FileUtils.touch(@metafile_path)
            @metafile_path.open('w') do |source|
              source.puts "metamodel_version '#{VERSION}'\n\n"
            end
          end
        end
      end

      private
    end
  end
end
