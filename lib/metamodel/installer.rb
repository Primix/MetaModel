module MetaModel
  class Installer
    require 'metamodel/installer/renderer'
    require 'metamodel/installer/validator'

    include Config::Mixin

    attr_reader :metafile

    attr_accessor :models
    attr_accessor :associations

    attr_accessor :current_model

    def initialize(metafile)
      @metafile = metafile
    end

    def prepare
      clone_project
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


    def install!
      @models = metafile.models
      @associations = metafile.associations
      UI.section "Generating model files" do
        Renderer.new(@models, @associations).tap do |renderer|
          renderer.render!
        end
      end

      update_initialize_method
      build_metamodel_framework unless config.skip_build?
    end

    def update_initialize_method
      template = File.read File.expand_path(File.join(File.dirname(__FILE__), "./template/metamodel.swift"))
      result = ErbalTemplate::render_from_hash(template, { :models => @models })
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

  end
end
