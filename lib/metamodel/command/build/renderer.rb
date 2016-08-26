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
          def render(model)
            template_path = File.expand_path(File.join(File.dirname(__FILE__), "../../template/model.swift.erb"))
            template = File.read template_path

            result = ErbalT::render_from_hash(template, { :model => model })
            model_path = Pathname.new("./MetaModel/MetaModel/#{model.name}.swift")
            File.write model_path, result

            project = Xcodeproj::Project.open(Config.instance.metamodel_xcode_project)
            target = project.targets.first

            target.source_build_phase.files_references.each do |file_ref|
              target.source_build_phase.remove_file_reference(file_ref) if file_ref && "#{model.name}.swift" == file_ref.name
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
end
