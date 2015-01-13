module VivoMapper
#  http://yehudakatz.com/2009/11/12/better-ruby-idioms/
  module MappableResource
    def map_with(map)
      @mapping = map
      send :include, InstanceMethods
    end

    def mapping
      @mapping
    end

    module InstanceMethods
      def stubbed
        @stubbed ||= false
      end

      def as_stub
        @stubbed = true
        self
      end

      def mapping
        self.class.mapping
      end

      def uri(namespace)
        mapping.uri(namespace,self)
      end

      def most_specific_type
        mapping.most_specific_type(self)
      end

      def additional_types
        mapping.additional_types(self) if mapping.respond_to?(:additional_types)
      end

      def properties
        mapping.properties(self)
      end

    end

  end

end
