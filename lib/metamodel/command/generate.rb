module MetaModel
  class Command
    class Generate < Command
      self.summary = "Generate a class skeleton for a model."
      self.description = <<-DESC
        Generate a skeleton for a Objective-C/Swift class and create
        this file as model.rb in MetaModel folder.
      DESC

      def initialize(argv)
        super
      end

      def run

      end

    end
  end
end
