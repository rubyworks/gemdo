require 'time'
require 'pom/corext'
require 'pom/readme'

#--
# TODO: method_missing
# TODO: extecutables is not right.
#++

module POM

  # = Metadata
  #
  # NOTE: It is tricky to get lazy loading and aliases to work together.
  # The following code is doing the job, but it probably needs to be
  # reimplemented in a better way.
  #
  class Metadata

    PRIMARY = ['project', 'name', 'version']

    # Like new but reads all metadata into memory.
    def self.load(root)
      new(root).load
    end

    #
    def self.attr_accessor(name)
      eval %{
        def #{name}
          load; @data["#{name}"]
        end
        def #{name}=(x)
          @data["#{name}"] = x
        end
      }
    end

    def self.alias_accessor(name, orig)
      #aliases[orig.to_sym] << name.to_sym
      #aliases[name.to_sym] << orig.to_sym
      #attr_accessor(name)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    # Glob for matching against meta directory names,
    # +.meta/+ and +meta/+.
    #METADIRS = '{.meta,meta}'
    METADIRS = ['.meta', 'meta']

    # Project root directory.
    attr :root

    ### Metadata directory.
    #attr :metafolder

    ### YAML based metadata file.
    #attr :metafile

    ### Version stamp.
    #attr :version_stamp

  private

    # New Metadata object.
    #
    def initialize(root)
      @root = Pathname.new(root.to_s)
      @data = {}

      # DEPRECATE package
      ['package', 'project', 'name', 'version'].each do |key|
        val = read(key)
        __send__("#{key}=", val) if val
      end

      @data['authors']   = []
      @data['requires']  = []
      @data['recommend'] = []
      @data['suggests']  = []
      @data['conflicts'] = []
      @data['replaces']  = []
      @data['provides']  = []

      @data['loadpath']   = ['lib']
      @data['distribute'] = ['**/*']

      #initialize_defaults
      #initialize_metafile

      #@version_stamp = Version.new(rootfolder)
    end

    #METAFILE = 'meta{,data}{.yaml,.yml}'

  public

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

    # Load metadata from the meta directory.
    def load
      @load ||= (
        # load meta directory entries
        METADIRS.reverse.each do |dir|
          next unless (@root + dir).directory?
          entries(dir).each do |file|
            data = File.read(@root + dir + file).strip
            data = (/\A^---/ =~ data ? YAML.load(data) : data)
            name = file.sub('/','_')
            if respond_to?("#{name}=")
              __send__("#{name}=", data)
            else
              #@data[name] = data
              add_attribute(name, data)
            end
          end
        end
        #if @meta_dir
        #  @meta_dir.glob('*').each do |f|
        #    send("#{f.basename}=", f.read.strip) if respond_to?("#{f.basename}=")
        #  end
        #end

        # load readme
        # TODO: move to ReadMe class?
        @data['description'] ||= readme.description
        @data['license']     ||= readme.license

        self
      )
    end

  private

    # Recurisve entries. Should be a method of Dir.
    def entries(dir)
      e = []
      paths = Dir.entries(dir.to_s) - ['.', '..']
      paths.each do |f|
        if File.directory?(File.join(dir, f))
          e.concat(entries(File.join(dir, f)).map{ |s| File.join(f,s) })
        else
          e << f
        end
      end
      e
    end

=begin
    # TODO: See if there is not a better way to do this... is lazy loading worth it?
    #
    def meta(name)
      return @data[name.to_s] if @data.key?(name.to_s)

      val = nil

      aliases = [name, *self.class.aliases[name.to_sym]]

      aliases.each do |n|
        val = metadir(n)
        break if val
      end

      aliases.each do |n|
        val = readme[n]
        break if val
      end unless val

      aliases.each do |n|
        val = default(n)
        break if val
      end unless val

      if respond_to?("#{name}=")
        send("#{name}=", val)
      else
        @data[name.to_s] = val
      end
    end
=end

    # Get metadata entry from meta-directory.
    def read(name)
      if file = root.first("{#{METADIRS.join(',')}}/#{name}")
        text = file.read.strip
        if /\A---/ =~ text
          YAML.load(text)
        else
          text
        end
      end
    end

    # Get metadata from README.
    def readme #(name=nil)
      @readme ||= Readme.new(root)
    end

    #
    #def method_missing(name, *args)
    #  metafile(name) || metadir(name) || readme(name) || default(name) || super
    #end

    #
    #def method_missing(name,*a,&b)
    #  return @meta[name] if @meta.key?(name)
    #  @meta[name] = meta(name)
      #if file = (rootfolder.glob("{meta,.meta}/#{name}").first
      #  @meta[name] = file.read.strip
      #elsif @default.key?(name)
      #  @meta[name] = @default[name]
      #else
      #  super
      #end
    #end

    #
    #def method_missing(name, *args)
    #  name = name.to_s
    #
    #  super if block_given?
    #  super if !args.empty?
    #  super if !metafolder
    #
    #  file = meta + name
    #  if file.exist?
    #    add_attribute(name, file.read)
    #  else
    #    super
    #  end
    #end

  private

    #
    def add_attribute(name, value)
      (class << self; self; end).class_eval do
        attr_accessor name
      end
      send("#{name}=", value)
    end

    #
    #def initialize_from_meta_directory
    #  if dir = (rootfolder / '.meta').directory?
    #    dir.glob('*').each do |f|
    #      send("#{f.basename}=", f.read.strip) if respond_to?("#{f.basename}=")
    #    end
    #  end
    #end

  public

    ######################
    # General Attributes #
    ######################

    # Project's package name. The entry is required
    # and must not contain spaces or puncuation.
    def name
      @data['name']
    end

    def name=(v)
      @data['name']=v
    end

    # Current version of the project. Should be a dot
    # separated string. Eg. "1.0.0".
    def version
      @data['version']
    end

    def version=(v)
      @data['version']=v
    end

    # Name of the user-account or master-project to which this project belongs.
    # The namespace defaults the project name if no entry is given.
    # TODO: Better term then namespace?
    attr_accessor :namespace

    # Current status (stable, beta, alpha, rc1, etc.)
    # DEPRECATE: (should be indicated by version number)
    attr_accessor :status

    # Date this version was released.
    attr_accessor :released

    # Code name of the release (eg. Woody)
    attr_accessor :codename


    # Title of package (this defaults to project name capitalized).
    attr_accessor :title

    # Platform (nil for universal)
    attr_accessor :platform

    # A one-line brief description.
    attr_accessor :summary

    # Detailed description. Aliased as #abstract.
    attr_accessor :description

    # Maintainer.
    attr_accessor :contact

    # Maintainer's Email (defaults to contact <...>).
    #attr_accessor :email

    # List of authors.
    attr_accessor :authors

    # Alias for authors.
    #alias_accessor :author, :author

    # The date the project was started.
    attr_accessor :created

    # Copyright notice.
    attr_accessor :copyright

    # License.
    attr_accessor :license

    # What other packages *must* this package have in order to function.
    attr_accessor :requires

    # What other packages *should* be used with this package.
    attr_accessor :recommend

    # What other packages *could* be useful with this package.
    attr_accessor :suggest

    # What other packages does this package conflict.
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
    attr_accessor :extensions    # Alias for #released.


    # Abirtary information, especially about what might be needed
    # to use this package. This is strictly information for the
    # end-user to consider. Eg. "Needs a fast graphics card."
    attr_accessor :notes

    # Homepage
    attr_accessor :homepage

    # Resource to find downloadable packages.
    attr_accessor :download

    # Location of central vcs repository.
    attr_accessor :repository

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright

    # TODO: Tecnically these next two are not metadata but build
    # configuration, so ultimately they should go else where.
    # But where?

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    attr_accessor :distribute

    # Map project directories and files to publish locations on webserver.
    attr_accessor :sitemap

  public

    ######################
    # Calculated Getters #
    ######################

    def namespace
      @data['namespace'] ||= name
    end

    # Title defaults to name captialized.
    def title
      @data['title'] ||= name.capitalize
    end

    # Summary will default to the first sentence or line
    # of the full description.
    def summary
      @data['summary'] ||= (
        if description
          i = description.index(/(\.|$)/)
          i = 69 if i > 69
          description.to_s[0..i]
        end
      )
    end

    # Extensions default to ext/**/extconf.rb
    def extensions
      @data['extensions'] ||= root.glob('ext/**/extconf.rb')
    end

    # Executables default to the contents of bin/.
    #def executables
    #  @executables ||= root.glob('bin/*').map{ |bin| File.basename(bin) }
    #end

    # Executables default to the contents of bin/.
    def executables
      @data['executables'] ||= root.glob('bin/*').collect{ |bin| File.basename(bin) }
    end

    # Contact defaults to the first author.
    #def contact
    #  @contact ||= authors.first
    #end

    # Contact's email address.
    def email
      if md = /<(.*?)>/.match(contact)
        md[1]
      else
        nil
      end
    end

    #
    def author
      authors.first
    end

    ######################
    # Calculated Setters #
    ######################

    #
    def author=(name)
      authors.unshift(name).uniq!
    end

    # Limit summary to 69 characters.
    def summary=(line)
      @data['summary'] = line[0..69]
    end

    #
    def released=(date)
      @data['released'] = Time.parse(date.strip) if date
    end

    #
    def loadpath=(paths)
      @data['loadpath'] = list(paths)
    end

    #
    def authors=(auths)
      @data['authors'] = list(auths)
    end

    #
    def requires=(x)
      @data['requires'] = list(x)
    end

    #
    def recommend=(x)
      @data['recommend'] = list(x)
    end

    #
    def suggest=(x)
      @data['suggest'] = list(x)
    end

    #
    def conflicts=(x)
      @data['conflicts'] = list(x)
    end

    #
    def replaces=(x)
      @data['replaces'] = list(x) #.to_list
    end

    #
    def provides=(x)
      @data['provides'] = list(x) #.to_list
    end

    #
    def distribute=(x)
      @data['distribute'] = list(x) #.to_list
    end

    #
    #def sitemap=(x)
    #  return @data['sitemap'] = nil unless x
    #  @data['sitemap'] = YAML.load(x) #.to_list
    #end

    ###########
    # Aliases #
    ###########

    # Alias for #name.
    alias_accessor :project    , :name

    # In previous versions #project used to mean what #namespace means, patterned after
    # the way in which Rubyforge organizes projects. Thus #package used to mean what #project
    # currently does. For the time being we keep an alias until all old usage is resloved.
    alias_accessor :package    , :name

    # Alias for #released.
    alias_accessor :date       , :released

    # Alias for #summary.
    alias_accessor :brief      , :summary

    # Alias for description.
    alias_accessor :abstract   , :description

    # Singularization of #requires is acceptable.
    alias_accessor :require    , :requires
    alias_accessor :dependency , :requires  # old terminology

    #alias_accessor :recommends , :recommend
    #alias_accessor :suggests   , :suggest

    alias_accessor :conflict   , :conflicts
    alias_accessor :provide    , :provides
    alias_accessor :replace    , :replaces

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

    ############
    # VALIDATE #
    ############

    # Is the minimal information provided?
    def valid?
      return false unless name
      return false unless version
      return false unless summary
      return false unless contact
      #return false unless homepage
    end

    # Assert that the mininal information if provided.
    def assert_valid
      raise "no name"    unless name
      raise "no version" unless version
      raise "no summary" unless summary
      raise "no contact" unless contact
      #raise "no homepage" unless homepage
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
      s << "package    : #{package}-#{version}"
      s << "requires   : #{requires.join(',')}"
      s.join("\n")
    end

    # Convert to YAML.
    def to_yaml
      load
      @data.to_yaml #super
    end

    #
    def save
      backup!
      dir = root.first('{meta,.meta}') || 'meta'
      @data.each do |name,value|
        path = name.sub(/\_+/, '/')
        file = root.first("{#{METADIRS.join(',')}}/#{path}")
        if file
          text  = file.read
          yaml  = /\A---/ =~ text
          value = value.to_yaml if yaml
          if text != value
            File.open(file, 'w'){ |f| f << value }
          end
        else
          path = dir + path
          FileUtils.mkdir_p(path.parent)
          File.open(path, 'w'){ |f| f << value.to_yaml }
        end
      end
    end

    # backup current metadata files to .cach/pom
    def backup!
      cache = root + '.cache/pom/'
      FileUtils.mkdir_p(cache)
      METADIRS.each do |meta|
        if (root + meta).directory?
          FileUtils.cp_r(root + meta, cache)
        end
      end
    end

  private

    # TODO: Use String#to_list instead (?)
    def list(l)
      case l
      when String
        l.split(/[:;\n]/)
      else
        [l.to_a].flatten.compact
      end
    end

  end#class Metadata

end#module POM

