require 'erb'
require 'ostruct'
require 'xcodeproj'

module MetaModel
  class Build
    class Renderer

      include Config::Mixin

      class ErbalT < OpenStruct
        def self.render_from_hash(t, h)
          ErbalT.new(h).render(t)
        end

        def render(template)
          ERB.new(template).result(binding)
        end
      end

      def templates
        templates = []
        file_paths = %w{file_header attributes json recordable initialize static_methods instance_methods model_query relation_query}
        file_paths.each do |file_path|
          templates << File.read File.expand_path(File.join(File.dirname(__FILE__), "template/#{file_path}.swift.erb"))
        end
        templates
      end

      class << self
        def render(model)
          result = templates.map { |template|
            ErbalT::render_from_hash(template, { :model => model })
          }.join("\n")
          puts result
          model_path = Pathname.new("./MetaModel/MetaModel/#{model.name}.swift")
          File.write model_path, result

          project = Xcodeproj::Project.open(config.metamodel_xcode_project)
          target = project.targets.first

          target.source_build_phase.files_references.each do |file_ref|
            target.source_build_phase.remove_file_reference(file_ref) if "#{model.name}.swift" == file_ref.name
          end

          models_group = project.main_group.find_subpath('MetaModel/Models', true)
          models_group.clear
          models_group.set_source_tree('SOURCE_ROOT')
          file_ref = models_group.new_reference Pathname.new("MetaModel/#{model.name}.swift")
          target.add_file_references [file_ref]

          project.save

        end
      end

      private

    end
  end
end
