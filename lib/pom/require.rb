require 'pom/core_ext/pathname'
#require 'pom/core_ext/try_dup'

module POM

  # The Require class provide access to REQUIRE file,
  # and models the categorized list of project dependencies.
  # In essence it is an array of Dependency objects.
  class Require

    include Enumerable

    # Default file name to use when saving
    # requirements to file.
    DEFAULT_FILE = 'REQUIRE.yml'

    # File glob pattern to use to find a project's
    # requirements file.
    FILE_PATTERN = '{,.}require{.yml,.yaml,}'

    # File glob pattern to use to find a project's
    # requirements file. This returns the constant
    # FILE_PATTERN value.
    def self.file_pattern
      FILE_PATTERN
    end

    # Find the first matching requirements file.
    def self.find(root)
      root = Pathname.new(root)
      root.glob(file_pattern, File::FNM_CASEFOLD).first
    end

    # Pathname of the requirements file.
    attr :file

    # List of Dependency objects.
    attr :dependencies

    # New requirements class.
    def initialize(root, file=nil)
      @root = Pathname.new(root)
      @file = file || self.class.find(root)

      @dependencies = []

      if @file && @file.exist?
        data = YAML.load(File.new(@file))
        merge!(data)
      else
        warn "No REQUIRE file at #{root}" if $DEBUG
      end
    end

    # Iterate over each dependency.
    def each(&block)
      dependencies.each(&block)
    end

    # Number of dependencies in total.
    def size
      dependencies.size
    end

    # List of required depenedencies. This works by removing
    # all optional dependencies from the #dependencies list.
    def requirements
      dependencies.reject{ |dep| dep.optional? }
    end

    # List of all development dependencies.
    def development
      dependencies.select{ |dep| dep.development? }
    end

    # Convert dependencies list into categorized YAML.
    def to_yaml(*args)
      env = {}
      dependencies.each do |dep|
        env[dep.group] ||= []
        env[dep.group] << dep.to_s
      end
      env.to_yaml(*args)
    end

    # Save dependency list to file in YAML format.
    def save!(file=nil)
      file = file || self.file || DEFAULT_FILE
      File.open(file, 'w'){ |f| f << to_yaml }
    end

    # Merge in another list of dependencies. This
    # can by a Hash or another Require object.
    def merge!(data)
      data.each do |group, deps|
        deps.each do |pkg|
          dep = Dependency.new(pkg, group)
          @dependencies << dep
        end
      end
      @dependencies.uniq!   
    end

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

  # The Dependecny class models a single project dependency,
  # consisting of the requirement's name, version constraint
  # and categorical grouping.
  #
  # TODO: In the future, dependencies may need to by SCM
  # repositories URIs, rather than simply package names.
  class Dependency

    # The package name and contraint. This is kept
    # as a single string, but under-the-hood is converted
    # into a VName object, which handles the name
    # a version contraints separately.
    attr :package

    # Categorical group to which the requirement belongs.
    attr :group

    # The first portion of the group is called the 
    # dependency's environment.
    attr :environment

    # The second portion of the group is called the 
    # dependency's subset.
    attr :subset

    # New dependency object.
    def initialize(package, group='runtime')
      self.package = package
      self.group   = group.to_s
    end

    # Set the package. This translates the package
    # setting into a VName object at the same time.
    def package=(package)
      @package = package
      @vname = VName.new(package)
    end

    # Set the categorical group. At the same time, parse
    # the goup into +environment+ and +subset+ values.
    def group=(group)
      @group = group
      @environment, @subset = group.split(/\//)
    end

    # Return the name of the package dependency.
    def name
      @vname.name
    end

    # Return the verion constraint of the package dependency.
    def version
      @vname.version
    end

    # Return the name and version contraint as a String.
    def to_s
      "#{name} #{version}".strip
    end

    # Same as #to_S, returning the name and version contraint
    # as a String.
    def inspect
      "#{name} #{version}".strip
    end

    # Is this dependency a runtime dependency? This means
    # it is need for the project to operate, or at least
    # operate for specific capacities.
    def runtime?
      environment == 'runtime' || environment == 'production'
    end

    # Alias for #runtime?
    alias_method :production?, :runtime?

    # Is thie an optional dependency? All development dependencies
    # and specifcally marked runtime dependencies are considered
    # optional. 
    def optional?
      development? || (runtime? && subset == 'optional')
    end

    # Dependencies that are not optional and not alternates are
    # considered *required* dependencies.
    def required?
      !(optional? || alternate?)
    end

    # A dependency is a development dependency if its environment is
    # set to 'development'.
    def development?
      environment == 'development' #or environment == 'dev'
    end

    # A dependency is a *test dependecny* if it is a development
    # dependency with a subet set to `test`.
    def test?
      development? && subset == 'test'
    end

    # A dependency is a *test dependecny* if it is a development
    # dependency with a subet set to `document`.
    def document?
      development? && subset == 'document'
    end

    #
    def vendored?
      subset == 'vendor'
    end

    # A dependency is an *alternate dependency* if its environment is
    # set to `alternate`. Alternate dependencies specify other packages
    # that can be used in exchange or cannot be used in conjunction with
    # the present package. They are not intended to have any (or at least much)
    # functional effect, but serve mosty to as a useful source of information
    # about the relationship between pacakges and their use of specifications.
    def alternate?
      environment == 'alternate'
    end

    # An alternative is a package that the present package can fulfill
    # the same basic API (more or less). For example the 'rdiscount' gem
    # can effectively provide the same functionality as the 'BlueCloth' gem.
    def alternative?
      alternate? && subset.empty?
    end

    # A replacement is an alternate dependency identifies by a subset
    # set to `replacement`. The setting asks, what other packages does this
    # package replace? This is very much like a regular alternative but
    # expresses a overriding relation. For instance "libXML" has been
    # replaced by "libXML2" --and the API might not be compatibile at all.
    def replacement?
      alternate? && subset == 'replacement'
    end

    # An conflict is a "dependency" (if we make take the liberty to call it
    # as much) identified by subset labeled `conflict`. A package is in conflict
    # with the present package when it will effectively break the operation
    # of the present package.
    def conflict?
      alternate? && subset == 'conflict'
    end

    # An provision is a dependency, identified by a subset labeled
    # `provision`. A provsion is an arbitrary term that succinctly
    # describes the functionaltiy of the present package. For example
    # the `rdiscount` gem can be said to provide `markdown` support
    # and may even specify a limiting version of that specification.
    def provision?
      alternate? && subset == 'provision'
    end

    # Converts the version into a constraint recognizable by RubyGems.
    # POM recognizes suffixed constraints as well as prefixed constraints.
    # This method converts suffixed constraints to prefixed constraints.
    #
    #   POM::Dependency.new('foo 1.0+').constraint
    #   #=> ">= 1.0"
    #
    # May I just comment that Ruby could really use a real Interval class
    # with proper support for infinity.
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

    # Compare dependencies for equality. Two depencies are equal
    # if they have the same name and teh same constraint.
    def ==(other)
      return false unless Dependency === other
      #return false unless group == other.group
      return false unless name == other.name
      return false unless constraint == other.constraint
      return true
    end

    # Compare dependencies for unique equality. Two depencies are
    # not unique if they have the same group, name and constraint.
    def eql?
      return false unless Dependency === other
      return false unless group == other.group
      return false unless name == other.name
      return false unless constraint == other.constraint
      return true
    end

    # "Spaceship" comparision. Returns +0+ if two
    # dependencies are equal. Otherwise it compares
    # their version contraints.
    def <=>(other)
      return 0 if self == other
      constraint <=> other.constraint
    end

    # Identifying hash, essentially the number characterizes the
    # nature of #eql?
    #
    # TODO: how best to define?
    def hash
      h = 0
      h ^= group.hash
      h *=137
      h ^= name.hash
      h *=137
      h ^= constraint.hash
      h
    end

  protected

    # VName encapsulates a name-verison pair.
    #
    # TODO: Need to support version "from-to" spans.
    class VName

      # Package name.
      attr :name

      # Package verison with constraint.
      attr :version

      # New VName object.
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

      # Returns a String with name and version.
      def to_s
        "#{name} #{version}"
      end

    private

      # Parse package entry into name and version constraint.
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

