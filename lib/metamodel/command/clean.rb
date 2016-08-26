module MetaModel
  class Command
    class Clean < Command
      require 'fileutil'

      self.summary = "Clean MetaModel project from current folder."
      self.description = <<-DESC

      DESC

      def initialize(argv)
        super
      end

      def run
        UI.section "Removing MetaModel project" do
          FileUtil.rm_rf 'MetaModel'
          FileUtil.rm_rf 'scaffold'
          UI.message "Already clean up the whole MetaModel project from current folder"
        end
      end

      private
    end
  end
end
