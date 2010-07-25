require 'pom/core_ext/pathname'
#require 'pom/core_ext/try_dup'

module POM
  # The Require class provide access to REQUIRE file,
  # and models the list of project requirements.
  # In essence it is an array of Requirement objects.
  class Requirements

    include Enumerable

    # Default file name to use when saving
    # requirements to file.
    DEFAULT_FILE = '.ruby/require'

    # File glob pattern to use to find a project's
    # requirements file.
    FILE_PATTERN = '{.ruby,}require{.yml,.yaml,}'

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
    attr :requirements

    # New requirements class.
    def initialize(root, file=nil)
      @root = Pathname.new(root)
      @file = file || self.class.find(root)

      @requirements = []

      if @file && @file.exist?
        reqs = YAML.load(File.new(@file))
        reqs.each do |req|
          @requirements << Requirement.new(req)
        end
      else
        warn "No `require' file at #{root}" if $DEBUG
      end
    end

    # Iterate over each dependency.
    def each(&block)
      requirements.each(&block)
    end

    # Number of requirements in total.
    def size
      requirements.size
    end

    # List of required depenedencies. This works by removing
    # all optional requirements from the #requirements list.
    def production
      requirements.reject{ |r| r.optional? }
    end
    alias_method :runtime, :production

    # List of all development requirements.
    def development
      requirements.select{ |r| r.development? }
    end

    # Convert requirements list into plain YAML.
    def yaml(*args)
      @requirements.map{ |r| r.to_h }.to_yaml
    end

    # Save requirements to file in YAML format.
    def save!(file=nil)
      file = file || self.file || DEFAULT_FILE
      File.open(file, 'w'){ |f| f << yaml }
    end

  end

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

