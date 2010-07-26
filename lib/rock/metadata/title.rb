class Rock::Metadata

  class Title < String

    def self.default(metadata)
      metadata.name.capitalized
    end

    include AbstractField

  end

end

