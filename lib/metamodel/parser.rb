module MetaModel

  class Parser(scaffold_folder_path)

    def initialize(scaffold_folder_path)
      @scaffold_folder_path = scaffold_folder_path
    end

  end

end

module MetaModel
  class CocoaModel

    attr_reader :properties

    class CocoaProperty
      attr_reader :json_key
      attr_reader :key
      attr_reader :type

      def initialize(json_key, type, key = nil)
        key |= json_key.underscore
        @key = key
        @json_key = json_key
        @type = type
      end
    end
  end
end
