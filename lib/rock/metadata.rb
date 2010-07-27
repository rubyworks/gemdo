require 'yaml'
require 'rock/root'

module Rock

  #
  class Metadata

    BACKUP_DIRECTORY = '.cache/rock/'

    #
    def self.register(type_class)
      type_class.names.each do |name|
        registry[name.to_sym] = type_class
      end
    end

    #
    def self.registry
      @registry ||= {}
    end

    #
    def initialize(root)
      @root = Pathname.new(root)
      load_sources
      initialize_defaults
    end

    #
    def dotruby
      @dotruby ||= DotRuby.new(@root)
    end

    #def name
    #  dotruby.name
    #end

    #def loadpath
    #  dotruby.loadpath
    #end

    def sources
      srcs = dotruby.metadata
      srcs = ['.ruby'] + srcs
      srcs.map do |file|
        @root + file
      end
    end

    def load_sources
      @zero  = {}
      @name  = {}
      @data  = {}
      sources.each do |source|
        next unless File.exist?(source)
        data = YAML.load(File.new(source))
        data.each do |key, value|
          if type = Metadata.registry[key.to_sym]
            mobj = type.new(value) #, self)
            @data[key.to_sym] = mobj
            @zero[key.to_sym] = source
            type.names.each do |name|
              @name[name.to_sym] = key.to_sym
            end
          else
            type = Metadata::Custom
            mobj = type.new(value) #, self)
            @zero[key.to_sym] = source
            @name[key.to_sym] = key.to_sym
            @data[key.to_sym] = mobj
          end
        end
      end
    end

    # Initialize defaults
    def initialize_defaults
      Metadata.registry.each do |key, type|
        if !@data.key?(key.to_sym)
          if type.respond_to?(:default)
            @data[key.to_sym] = type.default(self)
            type.names.each do |name|
              @name[name.to_sym] = key.to_sym
            end
          end
        end
      end
    end

    #
    def to_h
      h = {}
      @data.each do |k,v|
        h[k.to_s] = v.to_data
      end
      h
    end

    #
    def []=(key,value)
      if type = Metadata.registry[key]
        mobj = type.new(value) #, self)
        @zero[key.to_sym] ||= default_source
        @data[key.to_sym] = mobj
        type.names.each do |name|
          @name[name.to_sym] = key.to_sym
        end
      else
        type = Metadata::Custom
        mobj = type.new(value) #, self)
        @zero[key.to_sym] ||= default_source
        @name[key.to_sym] = key.to_sym
        @data[key.to_sym] = mobj
      end
    end

    #
    def [](key)
      @data[@name[key.to_sym]]
    end

    #
    def method_missing(sym,value=nil,*a,&b)
      key = sym.to_s.chomp('=').to_sym
      case sym.to_s
      when /\=$/
        self[key] = value
      else
        self[key]
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if @data[name.to_sym]
      return false
    end

    # Save metadata back to source files. This will not save a source if it
    # has not changed. Returns a list of the source files that were changed,
    # or +nil if none of the files were changed.
    #
    # TODO: Pretty ouput, but how?
    def save!
      saved = []
      table = Hash.new{|h,k| h[k]=[]}
      @data.each do |key, value|
        src = @zero[key]
        #table[src] ||= []
        table[src] << key
      end
      table.each do |src, keys|
        hash = {}
        keys.each do |key|
          hash[key.to_s] = self[key].to_data
        end
        data = normalize(YAML.load(File.new(src)))
        if data != hash
          backup!(src)
          File.open(src, 'w') do |f|
            f << hash.to_yaml
          end
          saved << src
        end
      end
      saved.empty? ? nil : saved
    end

    #
    def backup!(file=nil)
      if file
        dir = root + BACKUP_DIRECTORY
        FileUtils.mkdir_p(dir)
        FileUtils.cp(file, dir)
      else
        sources.each do |src|
          backup!(src)
        end
      end
    end

    ;; private

    #
    def normalize(data)
      hash = {}
      data.each do |k,v|
        case v
        when Date
          hash[k] = v #.strftime('%Y-%m-%d')
        else
          hash[k] = v
        end
      end
      hash
    end

  end

  require 'rock/metadata/abstract'
  Dir[File.join(File.dirname(__FILE__), 'metadata', '*.rb')].each do |rb|
    require rb
  end

end

=begin
  # The Metadata class encsulates a project's Package
  # and Profile data in a single interface.
  class MetadataOld

    # Metadata sources.
    attr :sources

    #
    def initialize(root, opts={})
      root = Pathname.new(root)

      @profile = nil
      @metadir = nil

      @dotruby = DotRuby.new(root)

      @package = Package.load(@dotruby.package)
      @profile = Profile.load(@dotruby.profile)

      # TODO: Add @profile.resources to lookup ?
      @sources = [@package, @profile].compact
    end

    # Load path(s) of the project, which are provided by the package.
    def loadpath
      @dotruby.loadpath
    end

    # The PACKAGE provides access to current package information.
    def package
      @package
    end

    # The PROFILE provides general information about the project.
    def profile
      @profile
    end

    # Name of the project, which is provided by the package.
    def name
      @package && @package.name
    end

    # Version of the project, which is provided by the package.
    def version
      @package && @package.version
    end

    # Save all metadata resources, i.e. package and profile.
    #def save!
    #  sources.each do |source|
    #    source.save!
    #  end
    #end

    # Backup all metadata resources to `.cache/rock` location.
    #def backup!
    #  sources.each do |source|
    #    source.backup!
    #  end
    #end

    # Delegate access to metdata sources.
    def method_missing(sym, *args, &blk)
      vals = []
      sources.each do |source|
        if source.respond_to?(sym)
          val = source.__send__(sym, *args, &blk)
          if val
            return val unless $DEBUG
            vals << val
          end
        end
      end
      # warn "multiple values that are not equal" ?
      vals.first
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
      s << "package    : #{name}-#{version}"
      s.join("\n")
    end

  end
=end

