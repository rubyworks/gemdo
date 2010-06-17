require 'pom/root'
require 'pom/package'
require 'pom/profile'
require 'pom/metadir'

module POM

  # = Metadata
  #
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

    # Release provides access to current release information.
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

    #
    def name
      @package.name
    end

    #
    def version
      @package.version
    end

    #
    def loadpath
      @package.loadpath
    end

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
      vals = []
      sources.each do |source|
        if source.respond_to?(sym)
          val = source.__send__(sym, *args, &blk)
          if val
            return val unless $DEBUG
          else
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
      s << "requires   : #{requires.join(',')}"
      s.join("\n")
    end

  private

    #
    #def version_file
    #  @version_file ||= root.glob('version{,.yml,.yaml,.txt}', File::FNM_CASEFOLD).first
    #end

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

