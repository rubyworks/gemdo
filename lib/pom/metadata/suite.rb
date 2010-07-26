class POM::Metadata

  #
  class Suite < String

    def self.aliases
      ['suite', 'collection', 'organization']
    end

    include AbstractField

  end

end

