require 'erb'
require 'ostruct'
require 'git'

module MetaModel

  class Render

    metamodel_template_uri = "https://github.com/Draveness/MetaModel-Template.git"

    class ErbalT < OpenStruct
      def self.render_from_hash(t, h)
        ErbalT.new(h).render(t)
      end

      def render(template)
        ERB.new(template).result(binding)
      end
    end

    def initialize(model)
      @model = model
      render
    end

    def render
      template = File.read File.expand_path(File.join(File.dirname(__FILE__), "template/model.swift.erb"))
      result = ErbalT::render_from_hash(template, { :model => @model })

      git = Git.init(metamodel_template_uri, 'metamodel', :path => config.installation_root)
      git.clone()
      puts result
    end

    private

  end
end
