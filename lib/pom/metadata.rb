require 'time'
require 'pom/root'
require 'pom/profile'
require 'pom/verfile'
require 'pom/metadir'

module POM

  # = Metadata
  #
  class Metadata

    #
    def initialize(root)
      root = Pathname.new(root)

      @sources = []

      if Verfile.find(root)
        @verfile = Verfile.new(root)
      end

      if Profile.find(root)
        @profile = Profile.new(root)
      end

      ## previous "confectionery" system (ahead of it's time, I'm afraid)
      #if Metadir.find(root)
      #  @metadir = Metadir.new(root)
      #end
    end

    # Profile provides all the general information about the project.
    def profile
      @profile
    end

    # Verfile provides all the current version information.
    def verfile
      @versfile
    end

    ##
    #def metadir
    #  @metadir
    #end

    #
    def save!
      each do |source|
        source.save!
      end
    end

    #
    def backup!
      each do |source|
        source.backup!
      end
    end

    #--
    # TODO: Add profile.resources to lookup ?
    #++
    def sources
      [verfile, profile, metadir]
    end

    #
    def method_missing(sym, *args, &blk)
      sources.each do |source|
        if source.respond_to?(sym)
          return source.__send__(sym, *args, &blk)
        end
      end
      nil
    end

  end

end

