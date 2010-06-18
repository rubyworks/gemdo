class POM::Package

  # Simple style VERSION file, is just a string.
  #
  #   1.0.0
  #
  module SimpleStyle

    #
    def self.match?(data)
      return false unless String === data
      /^\d+\.\S+$/ =~ data.strip
    end

    #
    def render
      version.to_s
    end

    #
    def parse(data)
      self.version = data.strip
    end

  end

end
