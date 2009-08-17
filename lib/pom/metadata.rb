require 'time'
require 'facets/pathname'
require 'pom/readme'

# TODO: method_missing
# TODO: extecutables is not right.

module POM

  # = Metadata
  #
  class Metadata

    def self.attr_accessor(name)
      eval %{
        def #{name}
          @#{name} ||= meta("#{name}")
        end

        def #{name}=(x)
          @#{name} = x
        end
      }
    end

    def self.alias_accessor(name, orig)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    METAFILE = 'meta{,data}{.yaml,.yml}'

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
    def initialize(rootdir)
      @root = Pathname.new(rootdir.to_s)

      #initialize_defaults

      if file = @root.glob_first(METAFILE, :casefold)
        @filedata = YAML.load(File.new(file))
      else
        @filedata = {}
      end

      readme = @root.glob('{README,README.*}').first
      @readme = Readme.load(readme) if readme

      # TODO: apply some code golf
      #if (rootfolder + '.meta').directory?
      #  @metafolder = rootfolder + '.meta'
      #elsif (rootfolder + 'meta').directory?
      #  @metafolder = rootfolder + 'meta'
      #end

      #initialize_from_meta_directory
      #if @metafolder
      #  @metafolder.glob('*').each do |f|
      #    send("#{f.basename}=", f.read.strip) if respond_to?("#{f.basename}=")
      #  end
      #end

      #@version_stamp = Version.new(rootfolder)
    end

    #
    def meta(name)
      return instance_variable_get("@#{name}") if instance_variable_defined?("@#{name}")

      val = metafile(name) || metadir(name) || readme(name) || default(name)

      if respond_to?("#{name}=")
        send("#{name}=", val)
      else
        instance_variable_set("@#{name}", val)
      end
    end

    # Get metadata from meta-file.
    def metafile(name)
      @filedata[name.to_s]
    end

    # Get metadata from meta-directory.
    #
    # TODO: Should +root+ be included as last resort?
    def metadir(name)
      if file = root.glob("{meta,.meta}/#{name}").first
        file.read.strip
      end
    end

    # Get metadata from README.
    def readme(name)
      @readme[name] if @readme
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

    # File pattern list of files to distribute in package.
    # This is provided to assist with MANIFEST automation.
    attr_accessor :distribute

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
      @executables ||= root.glob('bin/*').collect{ |bin| File.basename(bin) }
    end

  public

    #######################
    # Calculated Setters  #
    #######################

    # Limit summary to 69 characters.
    def summary=(line)
      @summery = line[0..69]
    end

    #
    def released=(date)
      @released = Time.parse(date.strip)
    end

    #
    def loadpath=(paths)
      @loadpath = list(paths)
    end

    #
    def authors=(auths)
      @authors = list(auths)
    end

    #
    def requires=(x)
      @requires = list(x)
    end

    #
    def recommends=(x)
      @recommends = list(x)
    end

    #
    def suggests=(x)
      @suggests = list(x)
    end

    #
    def conflicts=(x)
      @conflict = list(x)
    end

    #
    def replaces=(x)
      @replaces = list(x) #.to_list
    end

    #
    def provides=(x)
      @provides = list(x) #.to_list
    end

    #
    def distribute=(x)
      @distribute = list(x) #.to_list
    end

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
      to_yaml
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

