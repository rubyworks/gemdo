require 'pom/core_ext/pathname'
require 'pom/core_ext/try_dup'

module POM

  # NOTE: This API of the Reqfile is still in flux.
  #
  class Reqfile
    include Enumerable

    # TODO: Narrow naming.
    def self.filename
      ['REQUIRE', 'Require', '.require']
    end

    #
    def self.find(root)
      pattern = '{' + filename.join(',') + '}{,.cfg}'
      root.glob(pattern).first
    end

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
    def initialize(root)
      @root = Pathname.new(root)
      @file = self.class.find(@root)

      @stack = []
      @set   = nil
      @share = {}

      @dependencies  = []

      @replaces  = []
      @provides  = []
      @conflicts = []
      @optional  = []

      if @file && @file.exist?
        text  = File.read(@file)
        parse(text)
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
    def requires
      dependencies.reject{ |dep| dep.optional? }
    end
    alias_method :requirements, :requires

    # Returns an Array of Dependency filtered by group.
    def group(name)
      dependencies.select{ |dep| dep.groups.include?(name) }
    end

    # List of groups.
    def groups
      map{ |dep| dep.groups }.flatten(1).compact.uniq
    end

    # List of platforms.
    def platforms
      map{ |dep| dep.platforms }.flatten(1).compact.uniq
    end

    # List of engines.
    def engines
      eng = []
      each{ |dep| dep.engines.each{ |e| eng << e.name } }
      eng.compact.uniq
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
    def parse(text)
      share = {}
      lines = text.lines.to_a
      lines.each do |line|
        line = line.sub(/\#.*?$/,'').strip
        next if line.empty?

        options  = {}
        options[:optional] = true if line.chomp!('*')

        segments = line.strip.split(/\s{2,}/)
        package  = segments.shift

        if package.index(': ')
          share = parse_options(package)
          next
        end

        options.merge!(share)
        options.merge!(parse_options(segments))

        @dependencies << Dependency.new(package, options)
      end
    end

    private

    def parse_options(segments)
      options = {}
      segments.each do |option|
        key, value = option.split(': ')
        options[key] = value
      end
      options
    end

=begin
      case data
      when Array
        data.each do |entry|
          parse(entry)
        end
      when Hash
        data.each do |entry, opts|
          parse_entry(entry, opts || {})
        end
      when String
        parse_entry(data, opts)
      end
    end
=end

  private

=begin
    #
    def parse_entry(entry, opts=nil)
      words = entry.split(/\s+/)
      type  = words.first
      spec  = words[1..-1].join(' ')
      case type
      when 'general'
        parse(opts)
      when 'package', 'gem'
        parse_package(spec, opts)
      when 'group'
        parse_group(spec, opts)
      when 'optional'
        parse_optional(spec, opts)
      when 'engine'
        parse_engine(spec, opts)
      when 'platform'
        parse_platform(spec, opts)
      when 'source'
        parse_source(spec, opts)
      else
        if opts
          parse_group(type, opts)
        else
          parse_package((type + ' ' + spec).strip)
        end
      end
    end

    def parse_source(url, opts={})
      @share[:source] = url
    end

    def parse_group(name, cont)
      shared do
        @share[:group] ||= []
        @share[:group] << name
        parse(cont)
      end
    end

    # Optional group
    def parse_optional(name, cont)
      shared do
        @optional << name
        @share[:group] ||=[]
        @share[:group] << name
        @share[:optional] = true
        parse(cont)
      end
    end

    def parse_platform(platform, cont)
      shared do
        @share[:platform] = platform
        parse(cont)
      end
    end

    def parse_engine(engine, cont)
      shared do
        @share[:engine] = engine
        parse(cont)
      end
    end

    def parse_package(package, opts={})
      options = @share.merge(opts || {})
      options[:package] = package
      case @set
      when :conflicts
        @conflicts << Dependency.new(options)
      when :replaces
        @replaces << Dependency.new(options)
      else
        @dependencies << Dependency.new(options)
      end
    end
    #alias_method :gem, :package
    #alias_method :pkg, :package


    def shared(&block)
      @stack << @share.inject({}){|h,(k,v)| h[k] = v.try_dup; h}
      yield
      @share = @stack.pop
    end
=end

=begin
    #
    def parse_provides(*names)
      @provides.concat(names)
    end

    def parse_conflicts(cont)
      raise if @set  # single depth only
      @set = :conflicts
      parse(cont)
      @set = nil
    end

    def parse_replaces(cont)
      raise if @set  # single depth
      @set = :replaces
      parse(cont)
      @set = nil
    end
=end

  end

  #
  class Dependency

    attr :package

    attr :group

    attr :engine

    attr :platform

    attr_accessor :source

    attr_accessor :vendor #path ?

    attr_accessor :optional

    #
    def initialize(package, settings={})
      self.package = package
      @groups    = []
      @engines   = []
      @platforms = []
      @optional  = false
      settings.each do |k,v|
        __send__("#{k}=", v.try_dup)
      end
    end

    #
    def package=(package)
      @vname = VName.new(package)
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
    def engine=(engine)
      @engine = engine
      list(engine).each do |e|
        @engines << VName.new(e)
      end
    end

    attr_reader :engines

    #
    def platform=(platform)
      @platform  = platform
      @platforms = list(platform)
    end

    attr_reader :platforms

    #
    def group=(group)
      @group = group
      @groups = list(group)
    end

    #
    attr_reader :groups

    #
    def inspect
      "#{name} #{version}".strip
    end
 
    #
    def optional?
      @optional
    end

    #
    def required?
      !@optional
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
        value.split(/\s*\,\s*/)
      else
        value
      end
    end


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

