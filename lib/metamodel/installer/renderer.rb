require 'xcodeproj'

module MetaModel
  class Installer
    class Renderer

      attr_reader :project
      attr_reader :target

      attr_reader :models
      attr_reader :associations

      def initialize(models, associations)
        @models = models
        @associations = associations
        @project = Xcodeproj::Project.open(Config.instance.metamodel_xcode_project)
        @target = project.targets.first
      end

      def templates
        results = []
        # file_paths = %w{file_header attributes json recordable initialize static_methods instance_methods model_query model_relation}
        file_paths = %w{file_header table_initialize model_initialize model_update model_query model_delete static_methods helper}
        file_paths.each do |file_path|
          template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/#{file_path}.swift"))
          results << template
        end
        results
      end

      def render!
        render_model_files
        render_association_files
        @project.save
      end

      def render_model_files
        @models.each do |model|
          @target.source_build_phase.files_references.each do |file_ref|
            @target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{model.name}.swift" == file_ref.name
          end
        end
        models_group = @project.main_group.find_subpath('MetaModel/Models', true)
        models_group.clear
        models_group.set_source_tree('SOURCE_ROOT')

        file_refs = []
        @models.each do |model|
          result = templates.map { |template|
            ErbalTemplate::render_from_hash(template, { :model => model })
          }.join("\n")
          model_path = Pathname.new("./metamodel/MetaModel/#{model.name}.swift")
          File.write model_path, result

          file_refs << models_group.new_reference(Pathname.new("MetaModel/#{model.name}.swift"))

          UI.message '-> '.green + "Using #{model.name}.swift file"
        end
        @target.add_file_references file_refs
      end

      def render_association_files
        @associations.each do |association|
          @target.source_build_phase.files_references.each do |file_ref|
            @target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{association.class_name}.swift" == file_ref.name
          end
        end

        models_group = @project.main_group.find_subpath('MetaModel/Associations', true)
        models_group.clear
        models_group.set_source_tree('SOURCE_ROOT')

        file_refs = []
        @associations.each do |association|
          next unless association.relation.to_s.start_with? "has"
          template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../template/association.swift"))
          result = ErbalTemplate::render_from_hash(template, { :association => association })
          file_name = "#{association.class_name}.swift"
          File.write Pathname.new("./metamodel/MetaModel/#{file_name}"), result

          file_refs << models_group.new_reference(Pathname.new("MetaModel/#{file_name}"))

          UI.message '-> '.green + "Using #{file_name} file"
        end
        @target.add_file_references file_refs
      end

      private

    end
  end
end
