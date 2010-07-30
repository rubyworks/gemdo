require 'yaml'
require 'rock/root'
require 'rock/package'
require 'rock/profile'

module Rock

  # The Metadata class is a simple wrapper around the Package
  # and Profile class. It serves to provide a unified interface
  # to project metadata.
  class Metadata

    BACKUP_DIRECTORY = '.cache/rock/'

    #
    def self.register(type_class)
      type_class.names.each do |name|
        registry[name.to_sym] = type_class
      end
    end

    #
    def self.registry
      @registry ||= {}
    end

    #
    def initialize(root, *sources)
      @root    = Pathname.new(root)
      if sources.empty?
        package = Package.new(root)
        profile = Profile.new(root, :name=>package.name)
        sources = [package, profile]
      end
      @sources = sources
      initialize_defaults
    end

    #
    def sources
      @sources
    end

    #
    #def dotruby
    #  @dotruby ||= DotRuby.new(@root)
    #end

    # Initialize defaults
    #def initialize_defaults
    #  Metadata.registry.each do |key, type|
    #    if !@data.key?(key.to_sym)
    #      if type.respond_to?(:default)
    #        @data[key.to_sym] = type.default(self)
    #        type.names.each do |name|
    #          @name[name.to_sym] = key.to_sym
    #        end
    #      end
    #    end
    #  end
    #end

    #
    def to_h
      sources.inject({}) do |h, s|
        d = s.to_h.rekey(&:to_s)
        h.merge!(d); h
      end
    end

    #
    def []=(key,value)
      sources.each do |src|
        keq = "#{key}="
        return src.__send__(keq, value) if src.respond_to?(keq)
      end
    end

    #
    def [](key)
      sources.each do |src|
        return src.__send__(key) if src.respond_to?(key)
      end
    end

    #
    def method_missing(sym,value=nil,*a,&b)
      key = sym.to_s.chomp('=').to_sym
      case sym.to_s
      when /\=$/
        self[key] = value
      else
        self[key]
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if sources.any?{ |src| src.respond_to?(name) }
      return false
    end

    # Save metadata back to source files. This should not save a source if it
    # has not changed. Returns a list of the source files that were changed,
    # or +nil+ if none of the files were changed.
    def save!
      changed = []
      sources.each do |src|
        saved = src.save!
        changed << src if saved
      end
      changed.empty? ? nil : changed
    end

    # TODO: only backup if changed
    def backup!(file=nil)
      if file
        if File.exist?(file)
          dir = root + BACKUP_DIRECTORY
          FileUtils.mkdir_p(dir)
          FileUtils.cp(file, dir)
        end
      else
        sources.each do |src|
          backup!(src.file)
        end
      end
    end

  end

  #require 'rock/metadata/abstract'
  #Dir[File.join(File.dirname(__FILE__), 'metadata', '*.rb')].each do |rb|
  #  require rb
  #end

end

=begin
  # The Metadata class encsulates a project's Package
  # and Profile data in a single interface.
  class MetadataOld

    # Metadata sources.
    attr :sources

    #
    def initialize(root, opts={})
      root = Pathname.new(root)

      @profile = nil
      @metadir = nil

      @dotruby = DotRuby.new(root)

      @package = Package.load(@dotruby.package)
      @profile = Profile.load(@dotruby.profile)

      # TODO: Add @profile.resources to lookup ?
      @sources = [@package, @profile].compact
    end

    # Load path(s) of the project, which are provided by the package.
    def loadpath
      @dotruby.loadpath
    end

    # The PACKAGE provides access to current package information.
    def package
      @package
    end

    # The PROFILE provides general information about the project.
    def profile
      @profile
    end

    # Name of the project, which is provided by the package.
    def name
      @package && @package.name
    end

    # Version of the project, which is provided by the package.
    def version
      @package && @package.version
    end

    # Save all metadata resources, i.e. package and profile.
    #def save!
    #  sources.each do |source|
    #    source.save!
    #  end
    #end

    # Backup all metadata resources to `.cache/rock` location.
    #def backup!
    #  sources.each do |source|
    #    source.backup!
    #  end
    #end

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

  end
=end

