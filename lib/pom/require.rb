require 'pom/core_ext/pathname'
#require 'pom/core_ext/try_dup'

module POM

  # Access to REQUIRE file.
  #
  class Require
    include Enumerable

    #
    FILE_PATTERN = '{,.}require{.yml,.yaml,}'

    #
    def self.file_pattern
      FILE_PATTERN
    end

    #
    def self.find(root)
      root = Pathname.new(root)
      root.glob(file_pattern, File::FNM_CASEFOLD).first
    end

    #
    attr :file

    #
    attr :dependencies

    #
    attr :conflicts

    #
    attr :replaces

    #
    attr :provides

    #
    attr :optional

    #
    def initialize(root, file=nil)
      @root = Pathname.new(root)
      @file = file || self.class.find(root)

      @dependencies = []

      if @file && @file.exist?
        data = YAML.load(File.new(@file))
        data.each do |group, deps|
          deps.each do |pkg|
            dep = Dependency.new(pkg, group)
            @dependencies << dep
          end
        end
      else
        warn "No REQUIRE file at #{root}" if $DEBUG
      end
    end

    #
    def each(&block)
      dependencies.each(&block)
    end

    #
    def size
      dependencies.size
    end

    #
    def requirements
      dependencies.reject{ |dep| dep.optional? }
    end

    #
    def development
      dependencies.select{ |dep| dep.development? }
    end

    # TODO: Reqfile needs a specialized to_yaml

    # TODO: What about production vs. runtime?

=begin
    # Returns an Array of Dependency filtered by group.
    def group(name)
      dependencies.select{ |dep| dep.groups.include?(name) }
    end

    # List of groups.
    def groups
      map{ |dep| dep.groups }.flatten(1).compact.uniq
    end
=end

  end

  #
  class Dependency

    attr :package

    attr :group

    attr :environment

    attr :subset

    #
    def initialize(package, group)
      self.package = package
      self.group   = group
    end

    #
    def package=(package)
      @package = package
      @vname = VName.new(package)
    end

    #
    def group=(group)
      @group = group
      @environment, @subset = group.split(/\//)
    end

    #
    def name
      @vname.name
    end

    #
    def version
      @vname.version
    end

    #
    def inspect
      "#{name} #{version}".strip
    end

    #
    def runtime?
      environment == 'runtime'
    end

    #
    def optional?
      development? || runtime? && subset == 'optional'
    end

    #
    def required?
      !(optional? || alternate?)
    end

    #
    def development?
      environment == 'development' #or environment == 'dev'
    end

    #
    def test?
      development? && subset == 'test'
    end

    #
    def document?
      development? && subset == 'document'
    end

    #
    def vendored?
      subset == 'vendor'
    end

    #
    def alternate?
      environment == 'alternate'
    end

    #
    def provision?
      alternate? && subset == 'provision'
    end

    #
    def replacement?
      alternate? && subset == 'replacement'
    end

    #
    def conflict?
      alternate? && subset == 'conflict'
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

    # VName encapsulates a name-verison pair.
    class VName

      attr :name

      attr :version

      def initialize(name)
        @name, @version = parse(name)
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

      def to_s
        "#{name} #{version}"
      end

    private

      def parse(package)
        parts = package.strip.split(/\s+/)
        name = parts.shift
        vers = parts.empty? ? nil : parts.join(' ')
        [name, vers]
      end

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

