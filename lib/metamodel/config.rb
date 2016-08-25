require 'active_support/multibyte/unicode'

module MetaModel
  # Stores the global configuration of MetaModel.
  #
  class Config

    DEFAULTS = {
      :verbose             => false,
      :silent              => false,
    }

    public

    #-------------------------------------------------------------------------#

    # @!group Paths

    # @return [Pathname] the root of the MetaModel installation where the
    #         scaffold folder is located.
    #
    def installation_root
      current_dir = ActiveSupport::Multibyte::Unicode.normalize(Dir.pwd)
      current_path = Pathname.new(current_dir)
      unless @installation_root
        until current_path.root?
          if scaffold_path_in_dir(current_path)
            @installation_root = current_path
            break
          else
            current_path = current_path.parent
          end
        end
        @installation_root ||= Pathname.pwd
      end
      @installation_root
    end

    attr_writer :installation_root
    alias_method :project_root, :installation_root

    def metamodel_template_uri
      "git@github.com:Draveness/MetaModel-Template.git"
    end

    def scaffold_folder
      Pathname.new(scaffold_path).exist?
    end

    # Returns the path of the scaffold.
    #
    # @return [Pathname]
    # @return [Nil]
    #
    def scaffold_path
      @scaffold_path_in_dir ||= installation_root + 'scaffold'
    end

    # Returns the path of the scaffold folder in the given dir if any exists.
    #
    # @param  [Pathname] dir
    #         The directory where to look for the scaffold.
    #
    # @return [Pathname] The path of the scaffold.
    # @return [Nil] If not scaffold was found in the given dir
    #
    def scaffold_path_in_dir(dir)
      candidate = dir + 'scaffold'
      if candidate.exist?
        return candidate
      end
      nil
    end

    public

    #-------------------------------------------------------------------------#

    # @!group Singleton

    # @return [Config] the current config instance creating one if needed.
    #
    def self.instance
      @instance ||= new
    end

    # Sets the current config instance. If set to nil the config will be
    # recreated when needed.
    #
    # @param  [Config, Nil] the instance.
    #
    # @return [void]
    #
    class << self
      attr_writer :instance
    end

    # Provides support for accessing the configuration instance in other
    # scopes.
    #
    module Mixin
      def config
        Config.instance
      end
    end
  end
end
