require 'rock/version'

class Rock::Metadata

  class Version < Rock::VersionNumber

    def self.aliases
      ['vers']
    end

    def self.store
      "package.yml"
    end

    include AbstractField

    #def validate
    #  /^\d/ =~ value
    #end

    def to_data
      to_s
    end

  end

end

