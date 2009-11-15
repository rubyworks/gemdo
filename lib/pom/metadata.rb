require 'time'
require 'pom/corext'
require 'pom/root'
require 'pom/readme'

#--
# TODO: executables is not right.
#++

module POM

  # = Metadata
  #
  class Metadata

    # Like new but reads all metadata into memory.
    def self.load(root=Dir.pwd)
      new(root).load
    end

    #
    def self.attr_accessor(name)
      code = %{
        def #{name}
          @data["#{name}"]
        end
        def #{name}=(x)
          @data["#{name}"] = x
        end
      }
      eval code
    end

    #
    def self.attr_accessor_list(name)
      code = %{
        def #{name}
          @data["#{name}"]
        end
        def #{name}=(x)
          @data["#{name}"] = list(x)
        end
      }
      eval code
    end


    def self.alias_accessor(name, orig)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    # Glob for matching against meta directory names,
    # +.meta/+ and +meta/+.
    #METADIRS = '{.meta,meta}'
    METADIRS = ['.meta', 'meta']

    # Project root directory.
    attr :root

    ### Version stamp.
    #attr :version_stamp

  private

    # New Metadata object.
    #
    def initialize(root=Dir.pwd)
      @root = Pathname.new(root.to_s)
      @data = {}

      # DEPRECATE package
      #['package', 'project', 'name', 'version'].each do |key|
      #  val = read(key)
      #  __send__("#{key}=", val) if val
      #end

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
    def load
      load_version_stamp
      load_metadata_hidden
      load_metadata
      #METADIRS.reverse.each do |dir|
      #  next unless (@root + dir).directory?
      #  entries(@root + dir).each do |file|
      #    next if file.index(/[.]/)             # TODO: improve rejection filter
      #    data = File.read(@root + dir + file).strip
      #    data = (/\A^---/ =~ data ? YAML.load(data) : data)
      #    name = file.sub('/','_')
      #    if respond_to?("#{name}=")
      #      __send__("#{name}=", data)
      #    else
      #      #@data[name] = data
      #      add_attribute(name, data)
      #    end
      #  end
      #end
      self
    end

    def load_metadata
      metadir = @root + 'meta'
      return unless metadir.directory?
      entries(metadir).each do |file|
        name = file.to_s.sub(metadir.to_s + '/', '').gsub('/','_').gsub('/','_')
        #next if file.to_s.index(/[.]/)  # TODO: improve rejection filter
        self[name] = read(file)
      end
    end

    def load_metadata_hidden
      metadir = @root + '.meta'
      return unless metadir.directory?
      entries(metadir).each do |file|
        name = file.to_s.sub(metadir.to_s + '/', '').gsub('/','_')
        #next if name.to_s.index(/[.]/)  # TODO: improve rejection filter
        self[name] = read(file)
      end
    end

    # NOTE: I'm not sure this a good idea, as it adds an additional complexity.
    # Standardizing around meta/version, is probably a much better approach.
    def load_version_stamp
      if file = root.glob('{VERSION,Version,version}{,.txt}').first
        vers = YAML.load(File.new(file))
        case vers
        when Hash
          vers = vers.inject({}){ |h,(k,v)| h[k.to_s.downcase.to_sym] = v }
          @data['version'] = "#{vers[:major]}.#{vers[:minor]}.#{vers[:patch]}"
        when Array
          @data['version'] = vers.join('.')
        else #String
          @data['version'] = vers
        end
      end
    end

    #
    def []=(name, value)
      if respond_to?("#{name}=")
        __send__("#{name}=", value)
      else
        (class << self; self; end).class_eval do
          attr_accessor name
        end
        __send__("#{name}=", value)
      end
    end

  private

    # Recurisve entries. Should be a method of Dir.
    def entries(dir)
      dir.glob('**/*')
      #e = []
      #paths = Dir.entries(dir.to_s) - ['.', '..']
      #paths.each do |f|
      #  if File.directory?(File.join(dir, f))
      #    e.concat(entries(File.join(dir, f)).map{ |s| File.join(f,s) })
      #  else
      #   e << f
      #  end
      #end
      #e
    end

    # Get a metadata +entry+, where entry is a pathname.
    def read(entry)
      text = entry.read.strip
      data = (/\A^---/ =~ text ? YAML.load(text) : text)
    end

  public

    # A T T R I B U T E S

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr_accessor :name

    # Current version of the project. Should be a dot
    # separated string. Eg. "1.0.0".
    attr_accessor :version

    #def version=(v)
    #  @data['version'] = v
    #end

    # Current status (stable, beta, alpha, rc1, etc.)
    # DEPRECATE: Should be indicated trailing letter on version number?
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
    attr_accessor :extensions

    # Abirtary information, espeThe entry is required
    # and must not contain spaces or puncuation.cially about what might be needed
    # to use this package. This is strictly information for the
    # end-user to consider. Eg. "Needs a fast graphics card."
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

    # Resource to central SMC *public* repository. Eg.
    #
    #   git://github.com/protuils/pom.git
    #
    attr_accessor :repository

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright


    # TODO: Tecnically these next two are not metadata but build
    # configuration, so ultimately they should go else where.
    # But where?

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    #attr_accessor :distribute

    # Map project directories and files to publish locations on webserver.
    #attr_accessor :sitemap


    # S P E C I A L  G E T T E R S

    # The +suite+ name defaults to the project's +name+.
    def suite
      @data['suite'] ||= name
    end

    # Title defaults to name captialized.
    def title
      @data['title'] ||= name.to_s.capitalize
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
    def executables
      @data['executables'] ||= root.glob('bin/*').collect{ |bin| File.basename(bin) }
    end

    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    # Contact's email address.
    def email
      if md = RE_EMAIL.match(contact)
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
      @data['replaces'] = list(x)
    end

    #
    def provides=(x)
      @data['provides'] = list(x)
    end


    #
    #def distribute=(x)
    #  @data['distribute'] = list(x) #.to_list
    #end

    #
    #def sitemap=(x)
    #  return @data['sitemap'] = nil unless x
    #  @data['sitemap'] = YAML.load(x) #.to_list
    #end


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
      return false unless contact
      #return false unless homepage
    end

    # Assert that the mininal information if provided.
    def assert_valid
      raise ValidationError, "no name"    unless name
      raise ValidationError, "no version" unless version
      raise ValidationError, "no summary" unless summary
      raise ValidationError, "no contact" unless contact
      #raise ValidationError, "no homepage" unless homepage
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
      s << "package    : #{package}-#{version}"
      s << "requires   : #{requires.join(',')}"
      s.join("\n")
    end

    # Convert to YAML.
    def to_yaml
      @data.to_yaml #super
    end

    # Return metadata in Hash form.
    def to_h
      @data.dup
    end


    # P E R S I S T E N C E

    # Save metadata to <tt>meta/</tt> directory (or <tt>.meta/</tt> if it is found).
    def save
      dir = root.first('{meta,.meta}') || Pathname.new('meta')
      @data.each do |name,value|
        case value
        when String, Array, Hash
          next if value.empty?
        end
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
          case value
          when String
            File.open(path, 'w'){ |f| f << value }
          else
            File.open(path, 'w'){ |f| f << value.to_yaml }
          end
        end
      end
    end

    # Backup current metadata files to <tt>.cache/pom/</tt>.
    def backup!
      cache = root + '.cache/pom/'
      FileUtils.mkdir_p(cache)
      METADIRS.each do |meta|
        if (root + meta).directory?
          FileUtils.cp_r(root + meta, cache)
        end
      end
      cache
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

    #
    class ValidationError < ArgumentError  # :nodoc:
    end

  end#class Metadata

end#module POM

