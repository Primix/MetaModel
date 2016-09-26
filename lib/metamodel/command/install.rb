require 'git'

module MetaModel
  class Command
    class Install < Command
      include Config::Mixin
      self.summary = "Build a MetaModel.framework from Metafile"
      self.description = <<-DESC
        Clone a metamodel project template from GitHub, parsing Metafile, validating models,
        generate model swift file and build MetaModel.framework.
      DESC

      attr_accessor :models

      def initialize(argv)
        validate!
        super
      end

      def run
        UI.section "Building MetaModel.framework in project" do
          prepare
          installer = installer_for_config
          installer.install!
        end
        UI.section "Copying MetaModel.framework into Embedded Binaries phrase." do
          integrate_to_project
        end
        # UI.notice "Please drag MetaModel.framework into Embedded Binaries phrase.\n"
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

      def integrate_to_project
        xcodeprojs = Dir.glob("#{config.installation_root}/*.xcodeproj")
        project = Xcodeproj::Project.open(xcodeprojs.first)
        target = project.targets.first
        return if target.build_phases.find { |build_phase| build_phase.to_s == "[MetaModel] Embedded Frameworks"}

        # Get useful variables
        frameworks_group = project.main_group.find_subpath('MetaModel', true)
        frameworks_group.clear
        frameworks_group.set_source_tree('SOURCE_ROOT')
        frameworks_build_phase = target.build_phases.find { |build_phase| build_phase.to_s == 'FrameworksBuildPhase' }

        # Add new "Embed Frameworks" build phase to target
        embedded_frameworks_build_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
        embedded_frameworks_build_phase.name = '[MetaModel] Embedded Frameworks'
        embedded_frameworks_build_phase.symbol_dst_subfolder_spec = :frameworks
        target.build_phases << embedded_frameworks_build_phase

        # Add framework to target as "Embedded Frameworks"
        framework_ref = frameworks_group.new_file("./MetaModel.framework")
        build_file = embedded_frameworks_build_phase.add_file_reference(framework_ref)
        frameworks_build_phase.add_file_reference(framework_ref)
        build_file.settings = { 'ATTRIBUTES' => ['CodeSignOnCopy', 'RemoveHeadersOnCopy'] }
        project.save
      end

      def validate!
        # super
        raise Informative, 'No Metafile in current directory' unless config.metafile_in_dir(Pathname.pwd)
      end

      private
    end
  end
end
