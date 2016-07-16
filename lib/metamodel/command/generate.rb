module MetaModel
  class Command
    class Generate < Command
      self.summary = "Generate a class skeleton for a model."
      self.description = <<-DESC
      DESC

      def initialize(argv)
        super
      end

      def run
        puts "Running"
      end

    end
  end
end
