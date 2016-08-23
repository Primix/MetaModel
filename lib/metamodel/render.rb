module MetaModel

  class Render

    def initialize(model)
      @model = model
      render
    end

    def render
      content = ''
      content << header_template

      puts content
    end

    private

    def header_template
      <<-TEMPLATE.strip_heredoc
//
//  #{@model.model_name}.swift
//  MetaModel
//
//  Created by MetaModel script.
//
      TEMPLATE
    end

  end
end
