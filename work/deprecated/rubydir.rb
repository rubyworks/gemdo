require 'time'
require 'pathname'
require 'pom/root'
require 'pom/metastore'

#--
# TODO: executables is not right ?
#++

module POM

  #
  class RubyDir

    # Extra metadata can be stored in meta/ or .meta/.
    FILE_PATTERN = '.ruby'

    #
    def self.file_pattern
      FILE_PATTERN
    end

    #
    def self.find(root)
      root = Pathname.new(root)
      root.glob(file_pattern).select{ |f| f.directory? }.first
    end

  private

    #
    def initialize(root, prime={})
      @root  = Pathname.new(root)
      @store = @root + self.class.file_pattern
      set!(prime)
      load!
    end

  public

    #
    def set!(data)
      data.each do |k,v|
        __send__("#{k}=", v) if respond_to?("#{k}=")
      end
    end

    #
    #def initialize_preload
    #  if root
    #    name     # preload name
    #    version  # preload version
    #  end
    #end

    # Project root directory.
    def root
      @root
    end

    # Storage locations for metadata, namely .ruby/.
    def store
      @store
    end

    # Change the root location if +dir+.
    def root=(dir) 
      @root = Pathname.new(dir)
      #@paths = [@root + 'meta', @root + '.meta']
    end

    # A T T R I B U T E S

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr_accessor :name

    # Current version of the project. Should be a dot
    # separated string. Eg. "1.0.0".
    attr_accessor :version

    # Load path(s) (used by Ruby's own site loading and RubyGems).
    # The default is 'lib/', which is usually correct.
    attr_accessor :loadpath

    # Date this version was released.
    attr_accessor :date

    # Alias for #date.
    alias_method :released, :date
    alias_method :released=, :date=

    #
    alias_method :release_date, :date
    alias_method :release_date=, :date=

    # Name of the release.
    attr_accessor :moniker

    # Namespace of project.
    attr_accessor :namespace

    #
    def version=(raw)
      @version = VersionNumber.new(raw)
    end

    #
    def date=(val)
      case val
      when Date #, Time, DateTime
        @date = val
      else
        @date = Date.parse(val) if val
      end
    end

    #
    def loadpath=(val)
      case val
      when Array
        @loadpath = val
      else
        @loadpath = val.split(/\s+/)
      end
    end

    # Save metadata to directory.
    def save!
      FileUtils.mkdir(store) unless File.directory?(store)
      File.open(store + 'name', 'w'){ |f| f << name }
      File.open(store + 'version', 'w'){ |f| f << version.to_s }
      File.open(store + 'loadpath', 'w'){ |f| f << loadpath.join("\n") }
      File.open(store + 'date', 'w'){ |f| f << date.strftime('%Y-%m-%d') } if date
      File.open(store + 'namespace', 'w'){ |f| f << namespace } if namespace
      File.open(store + 'moniker', 'w'){ |f| f << moniker } if moniker
    end

    # Load metadata from directory.
    def load!
      store.glob('*').each do |file|
        next if file.basename.to_s.index(/^\./)
        name = file.basename #path_to_name(file, path)
        if respond_to?("#{name}=")
          __send__("#{name}=", File.read(file).strip)
        end
      end
      self     
    end

    #
    def load_from_package(package)
      self.name      = package.name
      self.version   = package.version
      self.loadpath  = package.loadpath
      self.date      = package.date
      self.moniker   = package.moniker
      self.namespace = package.namespace
    end

  end

end

