require 'colored'
require 'claide'

module MetaModel

  class Command < CLAide::Command
    self.abstract_command = true
    self.command = 'mm'
    self.version = VERSION
    self.description = 'MetaModel, the Model generator.'
    self.plugin_prefixes = %w(claide mm)
  end
end
