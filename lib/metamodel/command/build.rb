require 'git'

module MetaModel
  class Command
    class Build < Command
      include Config::Mixin
      require 'metamodel/command/build/resolver'
      require 'metamodel/command/build/renderer'
      require 'metamodel/command/build/translator'

      self.summary = "Build a MetaModel.framework from Metafile"
      self.description = <<-DESC
        Clone a metamodel project template from GitHub, parsing Metafile, validating models,
        generate model swift file and build MetaModel.framework.
      DESC

      attr_accessor :models

      def initialize(argv)
        super
      end

      def run
        UI.section "Building MetaModel.framework in project" do
          clone_project
          models, associations = resolve_template
          @models = compact_associtions_into_models models, associations
          validate_models
          render_model_files
          update_initialize_method
          build_metamodel_framework unless config.skip_build?
        end
        UI.notice "Please drag MetaModel.framework into Embedded Binaries phrase.\n"
      end

      def clone_project
        if File.exist? config.metamodel_xcode_project
          UI.message "Existing project `#{config.metamodel_xcode_project}`"
        else
          UI.section "Cloning MetaModel project into `./metamodel` folder" do
            Git.clone(config.metamodel_template_uri, 'metamodel', :depth => 1)
            UI.message "Using `#{config.metamodel_xcode_project}` to build module"
          end
        end
      end

      def resolve_template
        resolver = Resolver.new
        resolver.resolve
      end

      def compact_associtions_into_models(models, associations)
        Translator.new(models, associations).translate
      end

      def validate_models
        existing_types = @models.map { |m| m.properties.map { |property| property.type } }.flatten.uniq
        unsupported_types = existing_types - supported_types
        raise Informative, "Unsupported types #{unsupported_types}" unless unsupported_types == []
      end

      def render_model_files
        UI.section "Generating model files" do
          Renderer.render(@models)
        end
      end
#
      def update_initialize_method
        template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/metamodel.swift"))
        result = Renderer::ErbalTemplate::render_from_hash(template, { :models => @models })
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
            CODE_SIGN_IDENTITY= \
            clean build"
          build_iphonesimulator = "xcodebuild -scheme MetaModel \
            -project MetaModel/MetaModel.xcodeproj \
            -configuration Release -sdk iphonesimulator \
            -derivedDataPath './metamodel' \
            ONLY_ACTIVE_ARCH=NO \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGN_IDENTITY= \
            clean build"
          result = system "#{build_iphoneos} > /dev/null &&
            #{build_iphonesimulator} > /dev/null"

          raise Informative, 'Building framework failed.' unless result

          build_products_folder = "./metamodel/Build/Products"

          copy_command = "cp -rf #{build_products_folder}/Release-iphoneos/MetaModel.framework . && \
            cp -rf #{build_products_folder}/Release-iphonesimulator/MetaModel.framework/Modules/MetaModel.swiftmodule/* \
                    MetaModel.framework/Modules/MetaModel.swiftmodule/"
          lipo_command = "lipo -create -output MetaModel.framework/MetaModel \
            #{build_products_folder}/Release-iphonesimulator/MetaModel.framework/MetaModel \
            #{build_products_folder}/Release-iphoneos/MetaModel.framework/MetaModel"

          result = system "#{copy_command} && #{lipo_command}"

          raise Informative, 'Copy framework to current folder failed.' unless result
          UI.message "-> ".green + "MetaModel.framework located in current folder"
        end
      end

      def validate!
        super
        raise Informative, 'No Metafile in current directory' unless config.metafile_in_dir(Pathname.pwd)
      end

      private

      CURRENT_SUPPORTED_BUILT_IN_TYPES = %w[
        Int
        Double
        Float
        String
        Bool
        NSDate
      ]

      def built_in_types
        CURRENT_SUPPORTED_BUILT_IN_TYPES.map do |t|
          [t, "#{t}?"]
        end.flatten
      end

      def supported_types
        @models.reduce(CURRENT_SUPPORTED_BUILT_IN_TYPES) { |types, model|
          types << model.name.to_s
        }.map { |type|
          [type, "#{type}?"]
        }.flatten
      end

    end
  end
end
