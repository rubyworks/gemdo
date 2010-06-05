require 'time'
require 'pom/root'
require 'pom/profile'
require 'pom/verfile'
require 'pom/reqfile'
require 'pom/metadir'

module POM

  # = Metadata
  #
  class Metadata

    # Metadata sources.
    attr :sources

    #
    def initialize(root)
      root = Pathname.new(root)

      @verfile = Verfile.new(root)
      @profile = Profile.new(root)
      @reqfile = Reqfile.new(root)

      ## previous "confectionery" system (ahead of it's time, I'm afraid)
      #if Metadir.find(root)
      #  @metadir = Metadir.new(root)
      #end

      # TODO: Add profile.resources to lookup ?
      @sources = [@verfile, @profile].compact #@metadir].compact
    end

    # Profile provides all the general information about the project.
    def profile
      @profile
    end

    # Verfile provides all the current version information.
    def verfile
      @verfile
    end

    #
    def reqfile
      @reqfile
    end

    ##
    #def metadir
    #  @metadir
    #end

    #
    def save!
      sources.each do |source|
        source.save!
      end
    end

    #
    def backup!
      sources.each do |source|
        source.backup!
      end
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

