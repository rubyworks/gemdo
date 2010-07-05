require 'pom/root'
require 'pom/package'
require 'pom/profile'
require 'pom/metadir'

module POM

  # The Metadata class encsulates a project's Package
  # and Profile data in a single interface.
  class Metadata

    # Metadata sources.
    attr :sources

    #
    def initialize(root, opts={})
      root = Pathname.new(root)

      @profile = nil
      @metadir = nil

      @package = Package.new(root, opts) #if Package.find(root)
      @profile = Profile.new(root, name) #if Profile.find(root)

      # DEPRECATE
      @metadir = Metadir.new(root) if Metadir.find(root)

      # TODO: Add @profile.resources to lookup ?
      @sources = [@package, @profile, @metadir].compact
    end

    # The PACKAGE provides access to current package information.
    def package
      @package
    end

    # The PROFILE provides general information about the project.
    def profile
      @profile
    end

    # Access to meta directory entries. For backward compatability,
    # maybe deprecated in future.
    def metadir
      @metadir
    end

    # Name of the project, which is provided by the package.
    def name
      @package.name
    end

    # Version of the project, which is provided by the package.
    def version
      @package.version
    end

    # Load path(s) of the project, which are provided by the package.
    def loadpath
      @package.loadpath
    end

    # Save all metadata resources, i.e. package and profile.
    def save!
      sources.each do |source|
        source.save!
      end
    end

    # Backup all metadata resources to `.cache/pom` location.
    def backup!
      sources.each do |source|
        source.backup!
      end
    end

    # Delegate access to metdata sources.
    def method_missing(sym, *args, &blk)
      vals = []
      sources.each do |source|
        if source.respond_to?(sym)
          val = source.__send__(sym, *args, &blk)
          if val
            return val unless $DEBUG
            vals << val
          end
        end
      end
      # warn "multiple values that are not equal" ?
      vals.first
    end

    # Provide a summary text of project's metadata.
    def to_s
      s = []
      s << "#{title} v#{version}"
      s << ""
      s << "#{summary}"
      s << ""
      s << "contact    : #{contact}"
      s << "homepage   : #{homepage}"
      s << "repository : #{repository}"
      s << "authors    : #{authors.join(',')}"
      s << "package    : #{name}-#{version}"
      s.join("\n")
    end

   private

    #
    #def meta_entry(name)
    #  if file = meta_file(name)
    #    File.read(file).strip
    #  else
    #    nil
    #  end
    #end

    #
    #def meta_file(name)
    #  root.glob("{,.}meta/#{name}").first
    #end
  end
end

