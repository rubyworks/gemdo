class Rock::Metadata

  class Title < String

    def self.default(metadata)
      metadata.name.capitalize
    end

    include AbstractField

  end

end

