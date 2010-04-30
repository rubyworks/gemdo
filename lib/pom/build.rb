require 'pom/filestore'

module POM

  #
  class Build < FileStore # :nodoc:

    ##
    # What packages this project requires for development,
    # sometimes called 'build requirements'.
    # :attr_accessor: requires
    attr_list :requires

    ##
    # External requirements, outside of the normal packaging system.
    # :attr_accessor: externals
    attr_list :externals

    ##
    # File pattern list of files to distribute in package.
    # This could, for instance, be used to assist with MANIFEST
    # generation.
    # :attr_accessor: distribute
    attr_list :distribute

    # Map project directories and files to publish locations on
    # the webserver. This entry might be used to publish a project
    # website.
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
    #def requires=(x)
    #  @data['requires'] = x.to_list
    #end

    #
    #def externals=(x)
    #  @data['externals'] = x.to_list
    #end

    #
    #def distribute=(x)
    #  @data['distribute'] = x.to_list
    #end

    #
    def sitemap=(x)
      return @data['sitemap'] = nil unless x
      @data['sitemap'] = YAML.load(x) #.to_list
    end

  end

end
