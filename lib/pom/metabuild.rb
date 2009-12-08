require 'pom/metastore'

module POM

  # = MetaBuild
  #
  # Metadata for build tasks.
  #
  class Metabuild < Metastore

    #DIRS = ['.config/build', 'config/build']

    #
    STORE_DIRECTORY = 'config/build'

    #
    def store
      STORE_DIRECTORY
    end

  private

    #
    def initialize_defaults
      @data = {}
      @data['dependencies'] = []
      @data['distribute']   = ['**/*']

      webdir = root.glob('site,website,web').first || 'site'
      @data['sitemap'] = { webdir => '.' }
    end

  public

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    attr_accessor :distribute

    # Map project directories and files to publish locations
    # on the webserver.
    attr_accessor :sitemap

    # Build dependencies --list of libraries that
    # are required for build tasks.
    attr_accessor :dependencies


    # S P E C I A L  S E T T E R S

    #
    def distribute=(x)
      @data['distribute'] = list(x) #.to_list
    end

    #
    def sitemap=(x)
      return @data['sitemap'] = nil unless x
      @data['sitemap'] = YAML.load(x) #.to_list
    end

  end

end

