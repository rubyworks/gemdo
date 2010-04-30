require 'time'
require 'pom/root'
require 'pom/filestore'

#--
# TODO: executables is not right ?
#++

module POM

  # = Metadata
  #
  class Metadata < FileStore

    # Storage locations for metadata. POM supports
    # the use of +meta/+ or the hidden +.meta/+.

    STORES = ['meta', '.meta']

    #
    def self.require_plugins
      #require 'pom/metadata/build'
      require 'pom/metadata/rubyforge'
    end

    #
    #def self.path
    #  'meta'
    #end

    # Like new but reads all metadata into memory.
    #--
    # TODO: search for root ?
    #++
    def self.load(root=Dir.pwd)
      o = new(root)
      o.load!
      o
    end

    # If creating new metadata from scratch, use this to prefill
    # entries to new project defaults.

    def self.new_project(root=Dir.pwd)
      prime = { 
        'name'       => File.basename(root),
        'version'    => '0.0.0',
        'requires'   => [],
        'summary'    => "FIX: brief one line description here",
        'contact'    => "FIX: name <email> or uri",
        'authors'    => "FIX: names of authors here",
        'repository' => "FIX: master public repo uri"
      }
      o = new(root, prime)
      if path = new_project_config
        o.load!(path)
      end
      return o
    end

    # Load per-user config values for a new project.
    # This is used by the 'pom init' command.

    def self.new_project_config
      new_project_defaults.each do |name, value|
        self[name] = value
      end
      home_config = ENV['XDG_CONFIG_HOME'] || '~/.config'
      store = stores.find{ |s| s[0,1] != '.' }  # not hidden
      path  = Pathname.new(File.join(home_config, 'pom', store))
       path.exist? ? path : nil
    end

  private

    #
    def initialize(root=nil, prime={})
      if root
        @root  = Pathname.new(root)
        @store = STORES.find{ |dir| (@root + dir).directory? }
        super(@root, @store)
        #super(nil, @root + 'meta', @root + '.meta')
        @data = prime
        initialize_preload
      else
        super(nil, *stores)
      end
      #load!
    end

    #
    def initialize_preload
      if root
        load_version_stamp
        name     # preload name
        version  # preload version
      end
    end

    #
    #def initialize_defaults
    #  @data['authors']    = []
    #  @data['requires']   = []
    #  @data['recommend']  = []
    #  @data['suggest']    = []
    #  @data['conflicts']  = []
    #  @data['replaces']   = []
    #  @data['provides']   = []
    #  @data['loadpath']   = ['lib']
    #  @data['distribute'] = ['**/*']
    #end

    default_value :authors,    []
    default_value :requires,   []
    default_value :recommend,  []
    default_value :suggest,    []
    default_value :conflicts,  []
    default_value :replaces,   []
    default_value :provides,   []
    default_value :loadpath,   ['lib']
    default_value :distribute, ['**/*']

  public

    # Project root directory.
    def root
      @root
    end

    # Storage locations for metadata. POM supports
    # the use of +meta+ and the hidden +.meta+.

    def store
      @store
    end

    # Change the root location if +dir+.
    def root=(dir) 
      @root = Pathname.new(dir)
      #@paths = [@root + 'meta', @root + '.meta']
    end

    # DEPRECATED: Support for metafile.

    # YAML based metadata file.
    #attr :metafile

    # Load from meta.yml file, if used.
    #def initialize_metafile
    #  if file = @root.glob_first(METAFILE, :casefold)
    #    data = YAML.load(File.new(file))
    #    data.each do |k,v|
    #      if respond_to?("#{k}=")
    #        __send__("#{k}=", v)
    #      else
    #        @data[k] = v
    #      end
    #    end
    #  end
    #end

    # Load metadata from the +.meta+ and/or +meta+ directories.
    def load!(path=nil)
      if path
        super(path)
      else
        if root
          load_version_stamp
          super
        end
      end
      self
    end

    # NOTE: I'm not sure this a good idea, as it adds an additional
    # complexity. Standardizing around meta/version, is probably
    # a much better approach.
    #--
    # TODO: get name from this file too?
    #++
    def load_version_stamp
      if file = root.glob('{VERSION,Version,version}{,.txt}').first
        vers = YAML.load(File.new(file))
        case vers
        when Hash
          vers = vers.inject({}){ |h,(k,v)| h[k.to_s.downcase.to_sym] = v; h }
          @data['version'] = "#{vers[:major]}.#{vers[:minor]}.#{vers[:patch]}"
        when Array
          @data['version'] = vers.join('.')
        else #String
          @data['version'] = vers
        end
      end
    end

  public

    # A T T R I B U T E S

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr_accessor :name

    # Current version of the project. Should be a dot
    # separated string. Eg. "1.0.0".
    attr_accessor :version

    # Current status (stable, beta, alpha, rc1, etc.)
    # DEPRECATE: Should be indicated by trailing letter on version number?
    attr_accessor :status

    # Date this version was released.
    attr_accessor :released

    # Code name of the release (eg. Woody)
    attr_accessor :codename

    # Name of the user-account or master-project to which this project belongs.
    # The suite name defaults to the project name if no entry is given.
    # This is also aliased as #collection.
    attr_accessor :suite

    # Title of package (this defaults to project name capitalized).
    attr_accessor :title

    # Platform (leave +nil+ for universal).
    attr_accessor :platform

    # A one-line brief description.
    attr_accessor :summary

    # Detailed description. Aliased as #abstract.
    attr_accessor :description

    # Contact can be any sort of resource that is intended
    # to be the end-users initial point of contact. It could
    # be the url to a mailing list, or a url to a forum, or the
    # email address of the maintainer, etc.
    attr_accessor :contact

    # Maintainer. This is the package maintainers name and
    # optionally their email addresses, eg. "Trans <trans@foo.com>".
    attr_accessor :maintainer

    # List of authors.
    attr_accessor :authors

    # Alias for authors.
    #alias_accessor :author, :author

    # The date the project was started.
    attr_accessor :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright

    # License.
    attr_accessor :license

    # What other packages *must* this package have in order to function.
    # This includes any requirements neccessary for installation.
    attr_accessor :requires

    # What other packages *should* be used with this package.
    attr_accessor :recommend

    # What other packages *could* be useful with this package.
    attr_accessor :suggest

    # With what other packages does this package conflict.
    attr_accessor :conflicts

    # What other packages does this package replace. This is very much like #provides
    # but expresses a closser relation. For instance "libXML" has been replaced by "libXML2".
    attr_accessor :replaces

    # What other package(s) does this package provide the same dependency fulfilment.
    # For example, a package 'bar-plus' might fulfill the same dependency criteria
    # as package 'bar', so 'bar-plus' is said to provide 'bar'.
    attr_accessor :provides

    # Load path(s) (used by Ruby's own site loading and RubyGems).
    # The default is 'lib/', which is usually correct.
    attr_accessor :loadpath

    # Will always be bin/*.
    #attr_accessor :executables

    # List of non-ruby extension configuration scripts.
    # These are used to compile the extensions.
    attr_accessor :extensions

    # Abirtary information, especially about what might be needed
    # to use or build or use this package that does not fit under
    # +requires+. This is strictly information for the end-user
    # to consider, eg. "Needs gcc 4.4+" or "Needs fast graphics card".
    attr_accessor :notes

    # Homepage
    attr_accessor :homepage

    # Resource to development site and/or source code.
    attr_accessor :development

    # Resource to documentation.
    attr_accessor :documentation

    # Resource to downloadable packages.
    attr_accessor :download

    # Resource to discussion forum.
    attr_accessor :forum

    # Resource to mailing list.
    attr_accessor :mailinglist

    # Resource to wiki wiki.
    attr_accessor :wiki

    # Resource to project blog.
    attr_accessor :blog

    # Resource to issue tracker.
    attr_accessor :issues

    # Resource to central *public* repository. Eg.
    #
    #   git://github.com/protuils/pom.git
    #
    attr_accessor :repository


    # S P E C I A L  G E T T E R S

    # The +suite+ name defaults to the project's +name+.
    def suite
      self['suite'] ||= name
    end

    # Title defaults to name captialized.
    def title
      self['title'] ||= name.to_s.capitalize
    end

    # Summary will default to the first sentence or line
    # of the full description.
    def summary
      self['summary'] ||= (
        if description
          i = description.index(/(\.|$)/)
          i = 69 if i > 69
          description.to_s[0..i]
        end
      )
    end

    # Extensions default to ext/**/extconf.rb
    def extensions
      self['extensions'] ||= root.glob('ext/**/extconf.rb')
    end

    # Executables default to the contents of bin/.
    def executables
      self['executables'] ||= root.glob('bin/*').collect{ |bin| File.basename(bin) }
    end

    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    # Maintainers's email address.
    def email
      if md = RE_EMAIL.match(maintainer.to_s)
        md[0]
      else
        nil
      end
    end

    # Returns the first entry in the authors list.
    def author
      authors.first
    end

    # Package name is generally in the form of +name-version+,
    # or +name-version-platform+ if +platform+ is specified.
    #
    # TODO: Improve buildno support ?
    def package_name(buildno=nil)
      if buildno
        buildno = Time.now.strftime("%H*60+%M")
        versnum = "#{version}.#{buildno}"
      else
        versnum = version
      end

      if platform
        "#{name}-#{versnum}-#{platform}"
      else
        "#{name}-#{versnum}"
      end
    end

    #
    alias_method :stage_name, :package_name


    # S P E C I A L  S E T T E R S

    # Name assignment. The +entry+ must not contain spaces or puncuation.
    def name=(entry)
      raise ValidationError, "invalid name -- #{n}" unless /^[\w-]+$/ =~ entry
      @data['name'] = entry
    end

    #
    def author=(name)
      authors.unshift(name).uniq!
    end

    # Limit summary to 69 characters.
    def summary=(line)
      @data['summary'] = line.to_s[0..69]
    end

    #
    def released=(date)
      @data['released'] = Time.parse(date.strip) if date
    end

    #
    def loadpath=(paths)
      @data['loadpath'] = paths.to_list
    end

    #
    def authors=(auths)
      @data['authors'] = auths.to_list
    end

    #
    def requires=(x)
      @data['requires'] = x.to_list
    end

    #
    def recommend=(x)
      @data['recommend'] = x.to_list
    end

    #
    def suggest=(x)
      @data['suggest'] = x.to_list
    end

    #
    def conflicts=(x)
      @data['conflicts'] = x.to_list
    end

    #
    def replaces=(x)
      @data['replaces'] = x.to_list
    end

    #
    def provides=(x)
      @data['provides'] = x.to_list
    end


    # A L I A S E S

    #
    alias_accessor :collection , :suite

    alias_accessor :dependency , :requires  # old terminology

    #
    #def platform
    #  @platform ||= (
    #    if binary
    #      Platform.local.to_s
    #    else
    #      nil
    #    end
    #  )
    #end


    # V A L I D A T I O N

    # Is the minimal information provided?
    def valid?
      return false unless name
      return false unless version
      return false unless summary
      #return false unless maintainer
      #return false unless homepage
      true
    end

    # Assert that the mininal information if provided.
    def assert_valid
      raise ValidationError, "no name"    unless name
      raise ValidationError, "no version" unless version
      raise ValidationError, "no summary" unless summary
      #raise ValidationError, "no maintainer" unless maintainer
      #raise ValidationError, "no homepage"   unless homepage
    end


    # C O N V E R S I O N

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


    # S U P P O R T  M E T H O D S

    #private
    # Default values used when initializing POM for a project.
    # Change your initialization values in ~/.config/pom/meta/<name>.
    #def new_project_defaults
    #  { 'name'       => root.basename.to_s,
    #    'version'    => '0.0.0',
    #    'requires'   => [],
    #    'summary'    => "FIX: brief one line description here",
    #    'contact'    => "FIX: name <email> or uri",
    #    'authors'    => "FIX: names of authors here",
    #    'repository' => "FIX: master public repo uri"
    #  }
    #end

    public

    ## Load initialization values for a new project.
    ## This is used by the 'pom init' command.
    #def new_project
    #  new_project_defaults.each do |name, value|
    #    self[name] = value
    #  end
    #  home_config = ENV['XDG_CONFIG_HOME'] || '~/.config'
    #  store = stores.find{ |s| s[0,1] != '.' }  # not hidden
    #  path  = Pathname.new(File.join(home_config, 'pom', store))
    #  load!(path) if path.exist?
    #
    #  #default_entries = default_dir.glob('**/*')
    #  #default_entries.each do |path|
    #  #  name  = path_to_name(path, default_dir)
    #  #  #value = path.read
    #  #  defaults[name] = read(path)
    #  #end
    #  #defaults.each do |name, value|
    #  #  self[name] = value
    #  #end
    #end

    # P E R S I S T E N C E

    # Backup directory.

    def cache
      root + '.cache/pom'
    end

    # Backup current metadata files to <tt>.cache/pom/</tt>.

    def backup!(chroot=nil)
      self.root = chroot if chroot
      return unless stores.any?{ |dir| File.exist?(dir) }
      FileUtils.mkdir_p(cache) unless File.exist?(cache)
      stores.each do |store|
        temp, $DEBUG = $DEBUG, false
        FileUtils.cp_r(store, cache) if File.exist?(store)
        $DEBUG = temp
      end
      return cache
    end

    # Save metadata to <tt>meta/</tt> directory (or <tt>.meta/</tt> if it is found).

    def save!(chroot=nil)
      self.root = chroot if chroot
      super
    end

    # load metadata plugins
    require_plugins

  end#class Metadata

end#module POM

