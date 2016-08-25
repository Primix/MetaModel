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
      template = File.read File.expand_path(File.join(File.dirname(__FILE__), "template/model.swift.erb"))
      result = ErbalT::render_from_hash(template, { :model => @model })
      model_path = Pathname.new("./MetaModel/MetaModel/#{@model.name}.swift")
      p model_path
      File.write model_path, result
    end

    private

  end
end
