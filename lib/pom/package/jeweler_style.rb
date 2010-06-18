class POM::Package

  # Jeweler style VERSION file, e.g.
  #
  #   ---
  #   :major: 1
  #   :minor: 0
  #   :patch: 0
  #   :build: pre.1
  #
  module JewelerStyle

    #
    def self.match?(data)
      return false unless Hash === data
      data = data.inject({}){|h,(k,v)| h[k.to_sym]=v; h}
      keys = data.keys - [:major, :minor, :patch, :build]
      keys.empty?
    end

    #
    def render
      ":major: #{@segments[0]}\n" +
      ":minor: #{@segments[1]}\n" +
      ":patch: #{@segments[2]}\n" +
      ":build: #{@segments[3..-1]}\n"
    end

    #
    def parse(data)
      data = data.inject({}){|h,(k,v)| h[k.to_sym]=v; h}
      self.version = data.values_at(:major,:minor,:patch,:build).compact
    end

  end

end
