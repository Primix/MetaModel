require 'erb'
require 'ostruct'

module MetaModel

  class Render

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
      template_path = File.expand_path(File.join(File.dirname(__FILE__), "template/model.swift.erb"))
      template = File.read template_path
      puts template
      vars = { :model => @model }
      puts ErbalT::render_from_hash(template, vars)

    end

    private

    def template
      <<-TEMPLATE.strip_heredoc
      TEMPLATE
    end

  end
end
