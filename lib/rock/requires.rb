require 'rock/version'

module Rock #::Metadata

  # The Requires class models the list of project requirements.
  # Essentially it is an array of Requirement objects.
  class Requires < Array

    def self.aliases
      ['requirements']
    end

    # Default file name to use when saving
    # requirements to file.
    def self.store
      "require.yml"
    end

    #
    def self.default(metadata)
      new([])
    end

    include Enumerable

    #include AbstractField

    # New requirements class.
    def initialize(reqs)
      reqs.each do |req|
        case req
        when Requirement
          self << req
        else
          self << Requirement.new(req)
        end
      end
    end

    # List of required depenedencies. This works by removing
    # all optional requirements from the #requirements list.
    def production
      reject{ |r| r.optional? }
    end
    alias_method :runtime, :production

    # List of all development requirements.
    def development
      select{ |r| r.development? }
    end

    # Convert requirements list into plain YAML.
    def yaml
      map{ |r| r.to_h }.to_yaml
    end

    def to_data
      map{ |r| r.to_h }
    end
  end

  # The Requirement class models a single project dependency,
  # consisting of the requirement's name, version constraint
  # and categorical grouping.
  #
  # TODO: In the future, requirements may need SCM
  # repositories URIs, rather than simply package names.
  class Requirement

    # New dependency object.
    def initialize(data)
      case data
      when String
        name, vers, *group = *data.strip.split(/\s+/)
        self.name    = name
        self.version = vers
        self.group   = group
      else
        self.name    = data['name']
        self.version = data.values_at('version', 'vers').first
        self.group   = data.values_at('group', 'groups', 'type', 'types').compact
      end
    end

    # Return the name of the package dependency.
    def name
      @name
    end

    # Set the name of the package dependency.
    def name=(name)
      @name = name
    end

    # Return the verion constraint of the package dependency.
    def version
      @version
    end

    # Set version constraint.
    def version=(vers)
      @version = Rock::VersionConstraint.new(vers)
    end

    # Categorical group(s) to which the requirement belongs.
    def group
      @group
    end

    # Set the categorical group(s).
    def group=(groups)
      if String===groups
        groups = groups.strip.sub(/^[\(\[]/,'').sub(/[\)\]]$/,'')
        groups = groups.split(/\s+\/?\s+/)
      end
      @group = [groups].flatten
    end

    #
    alias_method :groups,  :group
    alias_method :groups=, :group=

    #
    alias_method :type,  :group
    alias_method :type=, :group=

    #
    def arch
      @arch
    end

    #
    def arch=(arch)
      @arch = arch
    end

    #
    alias_method :platform,  :arch
    alias_method :platform=, :arch=

=begin
    # An provision is a dependency, identified by a subset labeled
    # `provision`. A provsion is an arbitrary term that succinctly
    # describes the functionaltiy of the present package. For example
    # the `rdiscount` gem can be said to provide `markdown` support
    # and may even specify a limiting version of that specification.
    def provides
      @provides
    end

    #
    def provides=(provides)
      @provides = provides
    end
=end

    # Return the name and version contraint as a String.
    def to_s
      "#{name} #{version}".strip
    end

    #
    def to_h
      h = {}
      h['name']     = name
      h['version']  = version.to_s
      h['group']    = group
      h
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
      development? || groups.any?{ |g| /^opt/ -~ g }
    end

    # Dependencies that are not optional and not alternates are
    # considered *required* dependencies.
    def required?
      !(optional? || alternate?)
    end

    # A dependency is a development dependency if any group
    # starts with +dev+, +test+ or +doc+.
    def development?
      groups.any?{ |g| /^(dev|test|doc)/ =~ g }
    end

    # A dependency is a *test dependecny* if it's groups
    # start with +test+.
    def test?
      groups.any?{ |g| /^test/ =~ g }
    end

    # A dependency is a *documenation dependecny* if any
    # of it's groups start with +doc+.
    def document?
      groups.any?{ |g| /^doc/ =~ g }
    end

    # A dependency is marked as vendored if any of its groups start with
    # +vendor+. Vendored requirements need not be installed, as they 
    # are redistributed with the package itself (usually in the vendor/ dir).
    def vendored?
      groups.any?{ |g| /^vendor/ =~ g }
    end

    # A dependency is an *alternate dependency* if any of its groups
    # start with +alt+. Alternate dependencies specify other packages
    # that can be used in exchange or cannot be used in conjunction with
    # the present package. They are not intended to have any (or at least much)
    # functional effect, but serve mosty to as a useful source of information
    # about the relationship between pacakges.
    #
    # More concisely, an alternate is any requirement that is an *alternative*
    # *repalcement* or *conflict*.
    def alternate?
      alternative? or replacement? or conflict?
    end

    # An alternative is a package that the present package can fulfill
    # the same basic API (more or less). For example the 'rdiscount' gem
    # can effectively provide the same functionality as the 'BlueCloth' gem.
    def alternative?
      groups.any?{ |g| /^alt/ =~ g }
    end

    # A replacement is an alternate dependency identifies by groups starting
    # with +replace+. The setting asks, what other packages does this
    # package replace? This is very much like a regular alternative but
    # expresses a overriding relation. For instance "libXML" has been
    # replaced by "libXML2" --and the API might not be compatibile at all.
    def replacement?
      groups.any?{ |g| /^replace/ =~ g }
    end

    # An conflict is a "dependency" (if we make take the liberty to call it
    # as much) identified by groups starting with +conflict+. A package is
    # in conflict with the present package when it will effectively break
    # the operation of the present package.
    def conflict?
      groups.any?{ |g| /^conflict/ =~ g }
    end

    #
    def yaml
      s = []
      s << "name: #{name}"
      s << "vers: #{constraint}"
      s << "type: #{types.join('/')}"
      s.join("\n")
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

  end#class Requirement

end



=begin
  # Specification for various types of requirements.
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
      @vname = VName.new(package)
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

=begin
    # Returns an Array of Dependency filtered by group.
    def group(name)
      requirements.select{ |dep| dep.groups.include?(name) }
    end

    # List of groups.
    def groups
      map{ |dep| dep.groups }.flatten(1).compact.uniq
    end
=end




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
      @vname = VName.new(package)
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




=begin
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

  end
=end

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

