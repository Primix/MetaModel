require 'fileutils'

module MetaModel
  class Command
    class Clean < Command

      self.summary = "Clean MetaModel project from current folder."
      self.description = <<-DESC
        Remove MetaModel folder which contains MetaModel.xcodeproj and model
        files from current path.
      DESC

      def initialize(argv)
        super
      end

      def run
        UI.section "Removing MetaModel project" do
          FileUtils.rm_rf 'MetaModel'
          FileUtils.rm_rf 'MetaModel.framework'
          UI.message "Already clean up the whole MetaModel project from current folder"
        end
      end

      private
    end
  end
end
