require 'xcodeproj'

module MetaModel
  class Installer
    class Renderer
      include Config::Mixin

      attr_reader :project

      attr_reader :models
      attr_reader :associations

      def initialize(models, associations)
        @models = models
        @associations = associations
        @project = Xcodeproj::Project.open(Config.instance.metamodel_xcode_project)
      end

      SWIFT_TEMPLATES_FILES = %w(
        file_header
        table_initialize
        model_initialize
        model_update
        model_query
        model_delete
        static_methods
        helper
      )

      def model_swift_templates
        [].tap do |templates|
          SWIFT_TEMPLATES_FILES.each do |file_path|
            template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/#{file_path}.swift"))
            templates << template
          end
        end
      end

      def render!
        remove_previous_files_refereneces
        UI.section "Generating model files" do
          render_model_files
        end
        UI.section "Generating association files" do
          render_association_files
        end
        @project.save
      end

      def remove_previous_files_refereneces
        target = @project.targets.first

        @models.each do |model|
          target.source_build_phase.files_references.each do |file_ref|
            target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{model.name}.swift" == file_ref.name
          end
        end

        @associations.each do |association|
          target.source_build_phase.files_references.each do |file_ref|
            target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{association.class_name}.swift" == file_ref.name
          end
        end
      end

      def render_model_files
        target = @project.targets.first

        models_group = @project.main_group.find_subpath('MetaModel/Models', true)
        models_group.clear
        models_group.set_source_tree('SOURCE_ROOT')

        file_refs = []
        @models.each do |model|
          result = model_swift_templates.map { |template|
            ErbalTemplate::render_from_hash(template, { :model => model })
          }.join("\n")
          model_path = Pathname.new("./metamodel/MetaModel/#{model.name}.swift")
          File.write model_path, result

          file_refs << models_group.new_reference(Pathname.new("MetaModel/#{model.name}.swift"))

          UI.message '-> '.green + "Using #{model.name}.swift file"
        end
        target.add_file_references file_refs
      end

      def render_association_files
        target = @project.targets.first

        association_group = @project.main_group.find_subpath('MetaModel/Associations', true)
        association_group.clear
        association_group.set_source_tree('SOURCE_ROOT')

        file_refs = []
        @associations.each do |association|
          next unless association.relation.to_s.start_with? "has"
          template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/association.swift"))
          result = ErbalTemplate::render_from_hash(template, { :association => association })
          file_name = "#{association.class_name}.swift"
          File.write Pathname.new("./metamodel/MetaModel/#{file_name}"), result

          file_refs << association_group.new_reference(Pathname.new("MetaModel/#{file_name}"))

          UI.message '-> '.green + "Using #{file_name} file"
        end
        target.add_file_references file_refs
      end

      private

    end
  end
end
