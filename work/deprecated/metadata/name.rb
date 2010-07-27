class Rock::Metadata

  class Name < String

    def self.store
      "package.yml"
    end

    include AbstractField

    def required?
      true
    end

  end

end

