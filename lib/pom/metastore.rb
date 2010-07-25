require 'pom/core_ext'
require 'pom/errors'

module POM

  # MetaStore serves as the base class for the Metadata
  # class. It connects the file system to the POM model.
  class MetaStore

    # Parent store, or root pathname. The topmost store
    # should set this to the root pathname. All substores
    # use this to reference their parent store (akin to
    # parent directory).
    attr :parent

    # Filesystem path for the file store.
    attr :pathname

    # New file store. The +parent+ is either the parent
    # Pathname or FileStore and +directory+ is the name
    # of the subdirectory with in it. If this is a toplevel
    # FileStore then set +parent+ to +nil+.
    def initialize(parent, directory)
      @parent   = parent
      @data     = {}
      @pathname = (
        case parent
        when Pathname
          parent + directory
        when FileStore
          parent.pathname + directory
        else
          Pathname.new(directory)
        end
      )
    end

    #
    def method_missing(sym, *args)
      name = sym.to_s
      case name
      when /=$/
        super(sym, *args) unless args.size == 1
        self[name] = args.first
      else
        super(sym, *args) unless args.empty?
        self[name]
      end
    end

    # Get value from store by name. The value will
    # be cached so the file system is only hit once.
    def [](name)
      name = name.to_s
      if @data.key?(name)
        @data[name]
      else
        @data[name] = get!(name)
      end
    end

    # Set value.
    def []=(name, value)
      @data[name.to_s] = value
    end

    # Get a metadata +entry+, where entry is a pathname.
    # If it is a directory, will create a new FileStore object.
    def get!(name)
      case name
      when String, Symbol
        path = @pathname + name #.to_s
      else
        path = name
      end

      if path.directory?
        data = FileStore.new(self, path.basename)
      elsif path.file?
        text = path.read.strip
        data = (/\A^---/ =~ text ? YAML.load(text) : text)
        data = data.to_list if self.class.listings[name]
      else
        data = self.class.defaults[name]
        data = instance_eval(&data) if Proc === data
      end
      data
    end

    # List of available entries.
    def entries
      pathname.glob('*').map{ |path| File.basename(path) }
    end

    alias_method :keys, :entries

    # Has a value been loaded from the file system?
    def key?(name)
      @data.key?(name.to_s)
    end

    #
    def ignore
      []
    end

    # Return +root+ pathname. The root pathname is the topmost
    # point of entry of this metadata set, and is (almost
    # certainly) the project root directory.
    def root
      case parent
      when Pathname  then parent
      when FileStore then parent.root
      else nil
      end
    end

    #
    def inspect
      "#<#{self.class} #{@data.inspect}>"
    end

    ##
    #def initialize_attributes
    #  path.glob('*').each do |file|
    #    name = path_to_name(file, path)
    #    next unless name
    #    @_keys << name
    #    if not respond_to?(name)
    #      if /\W/ !~ name  # only files that are all word letters
    #        (class << self; self; end).class_eval do
    #          attr_accessor name
    #        end
    #      end
    #    end
    #  end
    #end

    # Subclasses can override this.
    def new_project_defaults
      {}
    end

    # Load attribute values from file system.
    def load!(alt_path=nil)
      path = alt_path ? Pathname.new(alt_path) : pathname()
      path.glob('*').each do |file|
        #next if file.to_s.index(/[.]/)  # TODO: rejection filter
        name = file.basename #path_to_name(file, path)
        self[name] = get!(file)
      end
      self
    end

    # Load attribute values from file system, but only if
    # the attribute is not currently set.
    def read!
      path = pathname
      path.glob('*').each do |file|
        #next if file.to_s.index(/[.]/)  # TODO: rejection filter
        name = file.basename #path_to_name(file, path)
        self[name] = get!(file) unless key?(name)
      end
      self
    end

    #
    def save!(path=nil)
      @pathname = Pathname.new(path) if path
      @pathname.mkdir unless @pathname.exist?
      @data.each do |name, value|
        write!(name, value)
      end
    end

  private

    # Write entry to file system.
    #--
    # TODO: escape filename for file system as needed
    #++

    def write!(name, value, overwrite=true)
      return if value.nil?
      fname = name # TODO
      file  = @pathname + fname
      if file.exist?
        if overwrite
          text  = file.read
          yaml  = /\A---/ =~ text
          value = value.to_yaml if yaml
          if text != value
            write_raw!(file, value)
          end
        end
      else
        case value
        when Array, Hash
          return if value.empty?
          out = value.to_yaml
        when String, Numeric
          out = value
        else
          out = value.to_yaml
        end
        write_raw!(file, out)
      end
    end

    # Write +output+ to a file referenced by the given +pathname+.
    # This method first ensures the pathname's parent directory exists.

    def write_raw!(pathname, output)
      FileUtils.mkdir_p(pathname.parent) unless pathname.parent.exist?
      File.open(pathname, 'w'){ |f| f << output }
    end

    # S U P P O R T  M E T H O D S

    #
    def path_to_name(path, prefix='')
      #return nil if file.to_s.index(/[.]/)  # TODO: rejection filter
      path = path.to_s
      path = path.sub(prefix.to_s.chomp('/') + '/', '')
      #path = path.gsub('/', '_')
      path
    end

  public

    # C O N V E R S I O N

    # Convert to YAML.
    #--
    # TODO: This might not be the best way to convert to YAML.
    #++
    def to_yaml
      to_h.to_yaml
    end

    # Return metadata in Hash form.
    def to_h
      read!
      @data.dup
    end

    # M O D I F I C A T I O N

    # Update underlying data table.
    def merge!(other)
      case other
      when Hash
        data = other
      when FileStore
        data = other.to_h
      end
      data.each do |name, value|
        @data[name.to_s] = value  
      end
    end

    # Like #merge! but does not update a value if it is *empty*.
    def mesh!(other)
      case other
      when Hash
        data = other
      when FileStore
        data = other.to_h
      end
      data.each do |name, value|
        case value
        when String, Array, Hash
          @data[name.to_s] = value unless value.empty?
        else
          @data[name.to_s] = value
        end
      end
    end

    # C L A S S  M E T H O D S

    # FileStore uses uniquely defined accessors.
    def self.attr_accessor(name, options={})
      defaults[name.to_s] = options[:default] if options[:default]
      listings[name.to_s] = true if options[:default] == []
      code = %{
        def #{name}
          self["#{name}"]
        end
        def #{name}=(x)
          self["#{name}"] = x
        end
      }
      eval code
    end

    # Stores default values for attributes.
    def self.defaults
      @defaults ||= {}
    end

    #What attributes are listings.
    def self.listings
      @listings ||= {}
    end

    ##
    #def self.alias_accessor(name, orig)
    #  alias_method(name, orig)
    #  alias_method("#{name}=", "#{orig}=")
    #end

  end

end

