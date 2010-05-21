require 'pom/core_ext/pathname'

module POM

  #
  class Package #PkgConfig
    include Enumerable

    # TODO: Narrow naming.
    def self.filename
      ['PACKAGE', 'Package', '.package', 'Pkgfile', '.pkgfile']
    end

    def self.find(root)
      pattern = '{' + filename.join(',') + '}{,.yml,.yaml}'
      root.glob(pattern).first
    end

    #
    attr :dependencies

    #
    def initialize(root)
      @root = Pathname.new(root)
      @file = self.class.find(@root)

      @dependencies  = []

      if @file && @file.exist?
        parse(@file)
      end
    end

    #
    def each(&block)
      @dependencies.each(&block)
    end

    def size
      @dependencies.size
    end

    # List of platforms.
    def platforms
      map{ |dep| dep.platform }.flatten
    end

    # List of engines.
    def engines
      map{ |dep| dep.engine }.flatten
    end

    # Returns a mapping of dependencies cross-indexed by engine and platform.
    def renditions
      deps = {}
      each do |dep|
        deps[[dep.engine,dep.platform]] ||= []
        deps[[dep.engine,dep.platform]] << self
      end
      deps
    end

    #
    def <<(entry)
      if String===entry
        entry = {'package'=> entry}
      end
      @dependencies << Dependency.new(entry)
    end

    # Parse dependency configuration file.
    def parse(file)
      data  = YAML.load(File.new(file))
      share = {}
      data.each do |entry|
        if String===entry
          entry = {'package'=> entry}
        end
        if entry['package']
          @dependencies << Dependency.new(share.merge(entry))
        else
          share.merge!(entry)
        end
      end
    end

  end

  #
  class Dependency

    attr_accessor :name

    attr_accessor :version

    attr_accessor :group

    attr_accessor :optional

    attr_accessor :source

    attr_accessor :engine

    attr_accessor :platform

    attr_accessor :path

    #
    def initialize(settings)
      settings.each do |k,v|
        __send__("#{k}=",v)
      end
    end

    #
    def package
      "#{name} #{version}"
    end

    #
    def package=(package)
      parts = package.strip.split(/\s+/)
      @name    = parts.shift
      @version = parts.empty? ? nil : parts.join(' ')
    end

    #
    def source=(source_list)
      @source = list(source_list)
    end

    #
    def group=(group_list)
      @group = list(group_list)
    end

    alias_method :groups, :group
    alias_method :groups=, :group=

    #
    def inspect
      "#{name} #{version}".strip
    end
 
    #
    def optional?
      @optional
    end

    #
    def development?
      group.include?('dev') || group.include?('development')
    end

    # Converts the version into a constraint recognizable by RubyGems.
    def constraint
      case version
      when /^(.*?)\~$/
        "~> #{$1}"
      when /^(.*?)\+$/
        ">= #{$1}"
      when /^(.*?)\-$/
        "< #{$1}"
      else
        version
      end
    end

  protected

    def list(value)
      case value
      when String
        value.split(/\s+/)
      else
        value
      end
    end

  end

=begin
  # Specification for various types of dependencies.
  class Requests

    # Versions of Ruby supported/tested.
    attr_accessor :ruby

    # Platforms supported/tested.
    attr_accessor :platforms

    # What other packages *must* this package have in order to function.
    # This includes any requirements neccessary for installation.
    attr_accessor :requires

    # What other packages *should* be used with this package.
    attr_accessor :recommend

    # What other packages *could* be useful with this package.
    attr_accessor :suggest #:optional?

    # With what other packages does this package conflict.
    attr_accessor :conflicts

    # What other package(s) does this package provide the same dependency
    # fulfilment. For example, a package 'bar-plus' might fulfill the same
    # dependency criteria as package 'bar', so 'bar-plus' is said to
    # provide 'bar'.
    attr_accessor :provides

    # What other packages does this package replace. This is very much
    # like #provides but expresses a overriding relation. For instance
    # "libXML" has been replaced by "libXML2".
    attr_accessor :replaces

    # External requirements, outside of the normal packaging system.
    attr_accessor :externals

    ## Abirtary point list, especially about what might be needed
    ## to use or build or use this package that does not fit under
    ## package category. This is strictly information for the end-user
    ## to consider, eg. "fast graphics card".
    #attr_accessor :consider

    #
    def initialize(data={})
      initialize_defaults
      data.each do |k,v|
        __send__("#{k}=", [v].flatten.compact)
      end
    end

    #
    def initialize_defaults
      @ruby      = []
      @platforms = ['all']
      @requires  = []
      @recommend = []
      @suggest   = []
      @conflicts = []
      @replaces  = []
      @provides  = []
      @externals = []
      #@consider  = []
    end

    #
    def merge(other)
      req = Requests.new
      req.requires  = requires  + other.requires
      req.recommend = recommend + other.recommend
      req.suggest   = suggest   + other.suggest
      req.conflicts = conflicts + other.conflicts
      req.replaces  = replaces  + other.replaces
      req.provides  = provides  + other.provides
      req.externals = externals + other.externals
      req
    end

  end
=end

end

