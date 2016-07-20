module MetaModel
  class Command
    class Build < Command
      self.summary = ""
      self.description = <<-DESC

      DESC

      def initialize(argv)
        super
      end

      def run
        Parser.new(config.scaffold_path)
      end

      private
    end
  end
end
