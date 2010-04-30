module POM

  # NOT YET USED. MIGHT NEVER BE USED B/C YAGNI.
  class Build < FileStore # :nodoc:

    # What other packages this project requires to build, ie. build requirements.
    attr_accessor :requires    #:dependencies

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    attr_accessor :distribute

    # Map project directories and files to publish locations
    # on the webserver.
    attr_accessor :sitemap

    # D E F A U L T S

    #
    def initialize_defaults
      @data = {}
      @data['dependencies'] = []
      @data['distribute']   = ['**/*']

      webdir = root.glob('site,website,web').first || 'site'
      @data['sitemap'] = { webdir => '.' }
    end

    # S P E C I A L  S E T T E R S

    #
    def distribute=(x)
      @data['distribute'] = x.to_list
    end

    #
    def sitemap=(x)
      return @data['sitemap'] = nil unless x
      @data['sitemap'] = YAML.load(x) #.to_list
    end

  end

end
