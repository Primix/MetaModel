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

    def install!
      @models = metafile.models
      @associations = metafile.associations
      Renderer.new(@models, @associations).tap do |renderer|
        renderer.render!
      end

      update_initialize_method
      build_metamodel_framework unless config.skip_build?
    end

    def update_initialize_method
      template = File.read File.expand_path(File.join(File.dirname(__FILE__), "./template/metamodel.swift"))
      result = ErbalTemplate::render_from_hash(template, { :models => @models, :associations => @associations })
      model_path = Pathname.new("./metamodel/MetaModel/MetaModel.swift")
      File.write model_path, result
    end

    def build_metamodel_framework
      UI.section "Generating MetaModel.framework" do
        build_framework_on_iphoneos
        build_framework_on_iphonesimulator
        copy_framework_swiftmodule_files
        lipo_frameworks_on_different_archs
      end
      UI.message "-> ".green + "MetaModel.framework located in current folder"
    end

    def build_framework_on_iphoneos
      build_iphoneos = "xcodebuild -scheme MetaModel \
        -project MetaModel/MetaModel.xcodeproj \
        -configuration Release -sdk iphoneos \
        -derivedDataPath './metamodel' \
        BITCODE_GENERATION_MODE=bitcode \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY= \
        clean build"
      result = system "#{build_iphoneos} > /dev/null"
      raise Informative, 'Building framework on iphoneos failed.' unless result
    end

    def build_framework_on_iphonesimulator
      build_iphonesimulator = "xcodebuild -scheme MetaModel \
        -project MetaModel/MetaModel.xcodeproj \
        -configuration Release -sdk iphonesimulator \
        -derivedDataPath './metamodel' \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY= \
        clean build"
        result = system "#{build_iphonesimulator} > /dev/null"
        raise Informative, 'Building framework on iphonesimulator failed.' unless result
    end

    BUILD_PRODUCTS_FOLDER = "./metamodel/Build/Products"

    def copy_framework_swiftmodule_files
      copy_command = "cp -rf #{BUILD_PRODUCTS_FOLDER}/Release-iphoneos/MetaModel.framework . && \
        cp -rf #{BUILD_PRODUCTS_FOLDER}/Release-iphonesimulator/MetaModel.framework/Modules/MetaModel.swiftmodule/* \
                MetaModel.framework/Modules/MetaModel.swiftmodule/"
      system copy_command
    end

    def lipo_frameworks_on_different_archs
      lipo_command = "lipo -create -output MetaModel.framework/MetaModel \
        #{BUILD_PRODUCTS_FOLDER}/Release-iphonesimulator/MetaModel.framework/MetaModel \
        #{BUILD_PRODUCTS_FOLDER}/Release-iphoneos/MetaModel.framework/MetaModel"
      result = system "#{lipo_command}"
      raise Informative, 'Copy framework to current folder failed.' unless result
    end

  end
end
