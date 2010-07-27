class Rock::Metadata

  class Loadpath < Array

    def self.default(metadata)
      ['lib']
    end

    include AbstractField

    #
    def initialize(path)
      case paths
      when NilClass
        replace ['lib']
      when String
        replace paths.split(/[,:;\ ]/)
      else
        replace [paths].flatten
      end
    end

  end

end

