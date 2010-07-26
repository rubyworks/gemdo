class POM::Metadata

  #
  class Summary < String

    #
    def self.default(metadata)
      d = metadata.description.to_s.strip
      i = d.index(/(\.|$)/)
      i = 69 if i > 69
      d[0..i]
    end

    #
    include AbstractField
  end

end

