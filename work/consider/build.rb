require 'pom/filestore'

module POM

  #
  class Build < FileStore # :nodoc:

    ##
    # What packages this project requires for development,
    # sometimes called 'build requirements'.
    # :attr_accessor: requires
    attr_accessor :requires, :default => []

    ##
    # External requirements, outside of the normal packaging system.
    # :attr_accessor: externals
    attr_accessor :externals, :default => []

    ##
    # File pattern list of files to distribute in package.
    # This could, for instance, be used to assist with MANIFEST
    # generation.
    # :attr_accessor: distribute
    attr_accessor :distribute, :default => ['**/*']

    # Map project directories and files to publish locations on
    # the webserver. This entry might be used to publish a project
    # website.
    attr_accessor :sitemap, :default => lambda{ {webdir => '.'} }

    # S P E C I A L  S E T T E R S

    #
    def sitemap=(x)
      return self['sitemap'] = nil unless x
      self['sitemap'] = YAML.load(x) #.to_list
    end

    private

      def webdir
        root.glob('site,website,web').first || 'site'
      end

  end

end
