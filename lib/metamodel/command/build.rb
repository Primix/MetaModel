require 'git'

module MetaModel
  class Command
    class Build < Command
      require 'metamodel/command/build/parser'
      require 'metamodel/command/build/renderer'

      self.summary = ""
      self.description = <<-DESC

      DESC

      attr_accessor :models

      def initialize(argv)
        super
      end

      def run
        UI.section "Building MetaModel.framework in project" do
          clone_project
          parse_template
          render_model_files
          update_initialize_method
          build_metamodel_framework
        end
        UI.notice "Please drag MetaModel.framework into Linked Frameworks and Libraries phrase.\n"
      end

      def clone_project
        if File.exist? config.metamodel_xcode_project
          UI.message "Existing project `#{config.metamodel_xcode_project}`"
        else
          UI.section "Cloning MetaModel project into `./metamodel` folder" do
            Git.clone(config.metamodel_template_uri, 'MetaModel')
            UI.message "Using `./metamodel/MetaModel.xcodeproj` to build module"
          end
        end
      end

      def parse_template
        parser = Parser.new
        @models = parser.parse
      end

      def render_model_files
        UI.section "Generating model files" do
          Renderer.render(@models)
        end
      end
      def update_initialize_method
        template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/metamodel.swift.erb"))
        result = ErbalT::render_from_hash(template, { :models => @models })
        model_path = Pathname.new("./metamodel/MetaModel/MetaModel.swift")
        File.write model_path, result
      end

      def build_metamodel_framework
        UI.section "Generating MetaModel.framework" do

          build_iphoneos = "xcodebuild -scheme MetaModel \
            -project MetaModel/MetaModel.xcodeproj \
            -configuration Release -sdk iphoneos \
            -derivedDataPath './metamodel' \
            BITCODE_GENERATION_MODE=bitcode \
            ONLY_ACTIVE_ARCH=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY="
          build_iphonesimulator = "xcodebuild -scheme MetaModel \
            -project MetaModel/MetaModel.xcodeproj \
            -configuration Release -sdk iphonesimulator \
            -derivedDataPath './metamodel' \
            ONLY_ACTIVE_ARCH=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY="
          result = system "#{build_iphoneos} && #{build_iphonesimulator}"

          raise Informative, 'Building framework failed.' unless result

          copy_command = "cp -rf metamodel/Build/Products/Release-iphoneos/MetaModel.framework . && \
            cp -rf metamodel/Build/Products/Release-iphonesimulator/MetaModel.framework/Modules/MetaModel.swiftmodule/* MetaModel.framework/Modules/MetaModel.swiftmodule/"
          lipo_command = "lipo -create -output MetaModel.framework/MetaModel \
            ./MetaModel/Build/Products/Release-iphonesimulator/MetaModel.framework/MetaModel \
            ./MetaModel/Build/Products/Release-iphoneos/MetaModel.framework/MetaModel"
          # os_result = system "cp -rf #{iphoneos_framework_path} #{config.installation_root}/"
          # simulator_result = system "cp -rf #{iphonesimulator_framework_path} #{config.installation_root}/"
          result = system "#{copy_command} && #{lipo_command}"
          raise Informative, 'Copy framework to current folder failed.' unless result
          UI.message "-> ".green + "MetaModel.framework located in current folder"
        end
      end

      def validate!
        super
        raise Informative, 'No meta folder in directory' unless config.meta_path_in_dir(Pathname.pwd)
      end

      private

      class ErbalT < OpenStruct
        def self.render_from_hash(t, h)
          ErbalT.new(h).render(t)
        end

        def render(template)
          ERB.new(template).result(binding)
        end
      end

    end
  end
end
