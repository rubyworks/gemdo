require 'time'
require 'facets/pathname'
require 'pom/readme'

# TODO: method_missing
# TODO: extecutables is not right.

module POM

  # = Metadata
  #
  # NOTE: It is tricky to get lazy loading and aliases to work together.
  # The following code is doing the job, but it probably needs to be
  # reimplemented in a better way.
  #
  class Metadata

    def self.aliases
      @aliases ||= Hash.new{|h,k| h[k]=[]}
    end

    def self.attr_accessor(name)
      eval %{
        def #{name}
          @data["#{name}"] ||= meta("#{name}")
        end

        def #{name}=(x)
          @data["#{name}"] = x
        end
      }
    end

    def self.alias_accessor(name, orig)
      aliases[orig.to_sym] << name.to_sym
      aliases[name.to_sym] << orig.to_sym
      attr_accessor(name)
      #alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    METADIRS = '{.meta,meta}'

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
    def initialize(rootdir, options={})
      @root = Pathname.new(rootdir.to_s)
      @data = {}

      if options[:load]
        initialize_metadirectory
      end

      #initialize_defaults
      #initialize_metafile

      #readme = @root.glob('{README,README.*}').first
      #@readme = Readme.load(readme) if readme

      #@version_stamp = Version.new(rootfolder)
    end

    #METAFILE = 'meta{,data}{.yaml,.yml}'

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

    # Load from meta directory.
    def initialize_metadirectory
      @root.glob("#{METADIRS}/**/*").each do |file|
        data = File.read(file)
        name = file.split('/')[1..-1].sub('/', '_')
        if respond_to?("#{name}=")
          __send__("#{name}=", data)
        else
          @data[name] = data
        end
      end
      #if @metafolder
      #  @metafolder.glob('*').each do |f|
      #    send("#{f.basename}=", f.read.strip) if respond_to?("#{f.basename}=")
      #  end
      #end
    end

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

    # Get metadata from meta-directory.
    #
    # TODO: Should +root+ be included as last resort?
    def metadir(name)
      if file = root.glob("#{METADIRS}/#{name}").first
        file.read.strip
      end
    end

    # Get metadata from README.
    def readme #(name=nil)
      @readme ||= Readme.new(root)
      #@readme[name] if name
    end

    #
    def default(name)
      if respond_to?("default_#{name}")
        send("default_#{name}")
      else
        nil
      end
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

    # Unixname of this application/library.
    attr_accessor :package

    # Unixname of the project to which this package belongs (defaults to package).
    attr_accessor :project

    # Version number of package.
    attr_accessor :version

    # Current status (stable, beta, alpha, rc1, etc.)
    # DEPRECATE: (should be indicated by version)
    attr_accessor :status

    # Date this version was released.
    attr_accessor :released

    # Code name of the release (eg. Woody)
    attr_accessor :codename


    # Title of package (this defaults to name capitalized).
    attr_accessor :title

    # Platform (nil for unviveral)
    attr_accessor :platform

    # A one-line brief description.
    attr_accessor :summary

    # Detailed description.
    attr_accessor :description

    # Maintainer.
    attr_accessor :contact

    # Maintainer's Email (defaults to contact <...>).
    #attr_accessor :email

    # List of authors.
    attr_accessor :authors

    # The date the project was started.
    attr_accessor :created

    # Copyright notice.
    attr_accessor :copyright

    # License.
    attr_accessor :license

    # What other packages *must* this package have in order to function.
    attr_accessor :requires

    # What other packages *should* be used with this package.
    attr_accessor :recommends

    # What other packages *could* be useful with this package.
    attr_accessor :suggests

    # What other packages does this package conflict.
    attr_accessor :conflicts

    # What other packages does this package replace.
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
    # to use this package. This is strictly information for the
    # end-user to consider. Eg. "Needs a fast graphics card."
    attr_accessor :notes

    # Homepage
    attr_accessor :homepage

    # Location of central vcs repository.
    attr_accessor :repository


    # TODO: Tecnically these next two are not metadata but build
    # configuration, so ultimately they should go else where.
    # But where?

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    attr_accessor :distribute

    # Map project directories and files to publish locations
    # on webserver.
    attr_accessor :sitemap


  #private # TODO: Would like to make this private except respond_to? in default() wouldn't work.

    #######################
    # Calculated Defaults #
    #######################

    def default_authors    ; [] ; end
    def default_requires   ; [] ; end
    def default_recommends ; [] ; end
    def default_suggests   ; [] ; end
    def default_conflicts  ; [] ; end
    def default_replaces   ; [] ; end
    def default_provides   ; [] ; end

    #
    def default_loadpath
      ['lib']
    end

    #
    def default_distribute
      ['**/*']
    end

    # Project name defaults to package name.
    def default_project
      package
    end

    # Title defaults to package name captialized.
    def default_title
      package.capitalize
    end

    # Summary will default to the first sentence or line
    # of the full description.
    def default_summary
      if description
        i = description.index(/(\.|$)/)
        i = 69 if i > 69
        description.to_s[0..i]
      end
    end

    # Extensions default to ext/**/extconf.rb
    def default_extensions
      root.glob('ext/**/extconf.rb')
    end

    # Executables default to the contents of bin/.
    #def default_executables
    #  root.glob('bin/*').collect{ |bin| File.basename(bin) }
    #end

    # Contact defaults to the first author.
    def default_contact
      authors.first
    end

    # Contact's email address.
    def default_email
      if md = /<(.*?)>/.match(contact)
        md[1]
      else
        nil
      end
    end

  public

    # Executables default to the contents of bin/.
    def executables
      @data['executables'] ||= root.glob('bin/*').collect{ |bin| File.basename(bin) }
    end

  public

    #######################
    # Calculated Setters  #
    #######################

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
    def recommends=(x)
      @data['recommends'] = list(x)
    end

    #
    def suggests=(x)
      @data['suggests'] = list(x)
    end

    #
    def conflicts=(x)
      @data['conflict'] = list(x)
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
    def sitemap=(x)
      @data['sitemap'] = YAML.load(x) #.to_list
    end


    #def rubyforge
    #  Functor.new do |op, *a|
    #    send("rubyforge_#{op}")
    #  end
    #end

    #def rubyforge_unixname
    #end

    #def rubyforge_groupid
    #end

    ###########
    # Aliases #
    ###########

    alias_accessor :name       , :package
    alias_accessor :date       , :released

    alias_accessor :brief      , :summary
    alias_accessor :abstract   , :description

    alias_accessor :require    , :requires
    alias_accessor :depend     , :requires  # old terminology
    alias_accessor :dependency , :requires  # old terminology

    alias_accessor :recommend  , :recommends
    alias_accessor :suggest    , :suggests
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

    #def exclude=(x)
    #  @exclude = list(x)
    #  @exclude << 'admin' #unless app.configuration.file?
    #  @exclude
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

    alias_method :stage_name, :package_name

    ############
    # VALIDATE #
    ############

    def valid?
      return false unless name
      return false unless version
      return false unless contact
      return false unless description
      #return false unless homepage
    end

    def assert_valid
      raise "no name"        unless name
      raise "no version"     unless version
      raise "no contact"     unless contact
      raise "no description" unless description
      #raise "no homepage"    unless homepage
    end

    #
    def to_s
      s = []
      s << "#{title} v#{version}"
      s << ""
      s << "#{description}"
      s << ""
      s << "contact    : #{contact}"
      s << "homepage   : #{homepage}"
      s << "repository : #{repository}"
      s << "authors    : #{authors.join(',')}"
      s << "package    : #{package}-#{version}"
      s << "requires   : #{requires.join(',')}"
      s.join("\n")
    end

    #
    def to_yaml
      preload
      @data.to_yaml #super
    end

    def preload
      @_preload ||= (
        meths = methods.select{ |m| /\w+\=$/ =~ m.to_s }
        meths = meths.map{ |m| m.to_s.chomp('=') }
        meths.each do |m|
          __send__(m)
        end
        true
      )
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

end#module Reap

