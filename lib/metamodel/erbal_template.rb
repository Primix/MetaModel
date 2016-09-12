require 'erb'
require 'ostruct'

module MetaModel
  class ErbalTemplate < OpenStruct
    def self.render_from_hash(t, h)
      ErbalTemplate.new(h).render(t)
    end

    def render(template)
      ERB.new(template).result(binding)
    end
  end
end
