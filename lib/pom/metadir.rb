require 'time'
require 'pom/root'
require 'pom/metastore'

#--
# TODO: executables is not right ?
#++

module POM

  # = Metadata
  #
  class Metadir < MetaStore

    # Storage locations for metadata. POM supports
    # the use of +meta/+ or the hidden +.meta/+.

    STORES = ['meta', '.meta']

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
        name     # preload name
        version  # preload version
      end
    end

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

    # Load metadata from the +.meta+ and/or +meta+ directories.
    def load!(path=nil)
      if path
        super(path)
      else
        if root
          #load_version_stamp
          super
        end
      end
      self
    end

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

    # Platforms this project/package supports (+nil+ for universal).
    attr_accessor :platforms

    ## Platform (leave +nil+ for universal).
    #attr_accessor :platform

    ##
    # Load path(s) (used by Ruby's own site loading and RubyGems).
    # The default is 'lib/', which is usually correct.
    # :attr_accessor: loadpath
    attr_accessor :loadpath, :default=>['lib']

    # Name of the user-account or master-project to which this project belongs.
    # The suite name defaults to the project name if no entry is given.
    # This is also aliased as #collection.
    attr_accessor :suite, :default => lambda{ name }

    #
    attr_accessor :collection, :default => lambda{ suite }

    # Title of package (this defaults to project name capitalized).
    attr_accessor :title, :default => lambda{ name.to_s.capitalize }

    # A one-line brief description.
    attr_accessor :summary, :default => lambda {
      if description
        i = description.index(/(\.|$)/)
        i = 69 if i > 69
        description.to_s[0..i]
      end
    }

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

    # The date the project was started.
    attr_accessor :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright

    # License.
    attr_accessor :license

    ##
    # List of authors.
    # :attr_accessor: authors
    attr_accessor :authors, :default=>[]

    ##
    # What other packages *must* this package have in order to function.
    # This includes any requirements neccessary for installation.
    # :attr_accessor: requries
    attr_accessor :requires, :default=>[]

    ##
    # External requirements, outside of the normal packaging system.
    # :attr_accessor: externals
    attr_accessor :externals, :default=>[]

    ##
    # What other packages *should* be used with this package.
    # :attr_accessor: recommend
    attr_accessor :recommend, :default=>[]

    ##
    # What other packages *could* be useful with this package.
    # :attr_accessor: suggest
    attr_accessor :suggest, :default=>[]

    ##
    # With what other packages does this package conflict.
    # :attr_accessor: conflicts
    attr_accessor :conflicts, :default=>[]

    ##
    # What other packages does this package replace. This is very much like #provides
    # but expresses a closser relation. For instance "libXML" has been replaced by "libXML2".
    # :attr_accessor: replaces
    attr_accessor :replaces, :default=>[]

    ##
    # What other package(s) does this package provide the same dependency fulfilment.
    # For example, a package 'bar-plus' might fulfill the same dependency criteria
    # as package 'bar', so 'bar-plus' is said to provide 'bar'.
    # :attr_accessor: provides
    attr_accessor :provides, :default=>[]

    # Abirtary information, especially about what might be needed
    # to use or build or use this package that does not fit under
    # +requires+. This is strictly information for the end-user
    # to consider, eg. "Needs gcc 4.4+" or "Needs fast graphics card".
    attr_accessor :consider

    # Will always be bin/*.
    #attr_accessor :executables

    # Executables default to the contents of bin/.
    attr_accessor :executables, :default => lambda {
      root.glob('bin/*').collect{ |bin| File.basename(bin) }
    }

    # List of extension configuration scripts.
    # These are used to compile the extensions.
    attr_accessor :extensions, :default => lambda{ root.glob('ext/**/extconf.rb') }

    # R E S O U R C E S

    # Offical project website.
    attr_accessor :homepage #home

    # Location of development site.
    attr_accessor :development  #work

    # Location of documentation.
    attr_accessor :documentation  #doc

    # Package distribution service webpage.
    attr_accessor :distribute

    # Downloadable packages.
    attr_accessor :download

    # Browse source code.
    attr_accessor :source

    # User discussion forum.
    attr_accessor :forum

    # Mailing list email or web address to online version.
    attr_accessor :mailinglist

    # Location of issue tracker.
    attr_accessor :issues

    # Location of support forum.
    attr_accessor :support

    # Location of API documentation.
    attr_accessor :api

    # Location of wiki-wiki.
    attr_accessor :wiki

    # Resource to project blog.
    attr_accessor :blog

    # IRC channel
    attr_accessor :irc

    # Resource for central *public* repository, e.g.
    #   git://github.com/protuils/pom.git
    attr_accessor :repository  #repo


    #
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
      self['name'] = entry
    end

    # Limit summary to 69 characters.
    def summary=(line)
      self['summary'] = line.to_s[0..69]
    end

    #
    def released=(date)
      self['released'] = Time.parse(date.strip) if date
    end

    #
    def author=(name)
      authors.unshift(name).uniq!
    end

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

    def to_verfile
      verfile = Verfile.new(root)
      verfile.name    = name
      verfile.version = version
      verfile.date    = released
      verfile.paths   = loadpath
      #verfile.state   = status
      verfile
    end

    OMIT = %w{status released codename loadpath}

    def to_profile
      #load!
      profile = Profile.new(root)
      to_h.each do |k,v|
        next if OMIT.include?(k.to_s)
        profile.__send__("#{k}=", v)
      end
      profile.resources.homepage = homepage
      profile.resources.repository = repository
      profile
    end

  end#class Metadata

end#module POM

