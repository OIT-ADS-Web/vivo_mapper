module VivoMapper
  class Resource

    attr_reader :stubbed

    def initialize
      @stubbed = false
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

    def properties
      mapping.properties(self)
    end

    def self.map_with(map)
      @mapping = map
    end

    def self.mapping
      @mapping
    end

 end
end
