require 'erb'
require 'ostruct'
require 'xcodeproj'

module MetaModel
  class Command
    class Build
      class Renderer
        class ErbalT < OpenStruct
          def self.render_from_hash(t, h)
            ErbalT.new(h).render(t)
          end

          def render(template)
            ERB.new(template).result(binding)
          end
        end

        class << self

          def templates
            results = []
            # file_paths = %w{file_header attributes json recordable initialize static_methods instance_methods model_query model_relation}
            file_paths = %w{file_header attributes recordable initialize static_methods instance_methods model_query model_relation}
            file_paths.each do |file_path|
              template = File.read File.expand_path(File.join(File.dirname(__FILE__), "../../template/#{file_path}.swift.erb"))
              results << template
            end
            results
          end

          def render(models)
            project = Xcodeproj::Project.open(Config.instance.metamodel_xcode_project)
            target = project.targets.first
            models.each do |model|
              target.source_build_phase.files_references.each do |file_ref|
                target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{model.name}.swift" == file_ref.name
              end
            end
            models_group = project.main_group.find_subpath('MetaModel/Models', true)
            models_group.clear
            models_group.set_source_tree('SOURCE_ROOT')

            file_refs = []
            models.each do |model|
              result = templates.map { |template|
                ErbalT::render_from_hash(template, { :model => model })
              }.join("\n")
              model_path = Pathname.new("./metamodel/MetaModel/#{model.name}.swift")
              File.write model_path, result

              file_refs << models_group.new_reference(Pathname.new("MetaModel/#{model.name}.swift"))

              UI.message '-> '.green + "Using #{model.name}.swift file"
            end
            target.add_file_references file_refs

            project.save
          end
        end

        private

      end
    end
  end
end
