require 'pom/core_ext'
require 'pom/errors'

module POM

  # FileStore serves as the base class for the Metadata
  # class. It connects the file system to the POM model.

  class FileStore

    #def self.registry
    #  @@registry ||= {}
    #end

    #
    #def self.inherited(base)
    #  registry[base.path.to_s] = base # FIXME: #path will not be defined yet, will it?
    #end

    #
    #def self.path
    #  name.split('::').last.downcase
    #end

    #
    #def self.factory(parent, path)
    #  name = File.basename(path)
    #  if registry.key?(name)
    #    registry[name].new(parent, path)
    #  else
    #    new(parent, path)
    #  end
    #end

    #
    def self.attr_accessor(name)
      code = %{
        def #{name}     ; self["#{name}"]     ; end
        def #{name}=(x) ; @data["#{name}"] = x ; end
      }
      eval code
    end

    #
    def self.alias_accessor(name, orig)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    #
    def self.default_value(name, value=nil, &block)
      if block_given?
        define_method("default_#{name}", &block)
      else
        define_method("default_#{name}"){ value }
      end
    end

  private

    #
    def initialize(parent, *dirs)
      @parent = parent
      @_dirs   = dirs.map{ |dir| Pathname.new(dir) }
      @_keys  = []
      @data   = {}
      initialize_attributes
      #load!
    end

    #
    def initialize_attributes(path=nil)
      if path
        path.glob('*').each do |file|
          name = path_to_name(file, path)
          next unless name
          @_keys << name
          if not respond_to?(name)
            (class << self; self; end).class_eval do
              attr_accessor name
            end
          end
        end
      else
        paths.each{ |path| initialize_attributes(path) }
      end
    end

    # Subclasses can override this.
    def new_project_defaults
      {}
    end

  public

    #

    def inspect
      "#<#{self.class} #{@data.inspect}>"
    end

    # Parent store, or root pathname. The topmost store
    # should set this to the root pathname. All substores
    # use this to reference their parent store (akin to
    # parent directory).

    attr :parent

    # Return +root+ pathname. The roo pathname is the topmost
    # point of entry of this metadata set, and is (almost
    # certainly) the project root directory.

    def root
      case parent
      when Pathname  then parent
      when FileStore then parent.root
      else nil
      end
    end

    # Paths in which to lookup data entries.

    def paths
      case parent
      when Pathname
        @_dirs.map{ |dir| parent + dir }
      when FileStore
        parent.paths.map{ |path| @_dirs.map{ |dir| path + dir } }.flatten.uniq
      else
        @_dirs
      end
    end

    #

    def [](name)
      name = name.to_s
      return @data[name] if @data.key?(name)
      dir = paths.find{ |path| (path + name).exist? }
      if dir
        self[name] = read!(dir + name)
      elsif respond_to?("default_#{name}")
        self[name] = __send__("default_#{name}")
      else
        self[name] = nil
      end
      @data[name]
    end

    #
    #def []=(name, value)
    #  @data[name.to_s] = value
    #end

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

    # Load attribute values from file system.

    def load!(path=nil)
      if path
        path.glob('*').each do |file|
          #next if file.to_s.index(/[.]/)  # TODO: rejection filter
          name = path_to_name(file, path)
          self[name] = read!(file)
        end
      else
        paths.each{ |path| load!(path) }
      end
    end

    # Load attribute values from file system, if and only if
    # the attribute is not currently set.

    def load_soft!(path=nil)
      if path
        path.glob('*').each do |file|
          #next if file.to_s.index(/[.]/)  # TODO: rejection filter
          name = path_to_name(file, path)
          self[name] = read!(file) unless @data.key?(name)
        end
      else
        paths.each{ |path| load_soft!(path) }
      end
    end

    #

    def save!(path=nil)
      self.paths = [Pathname.new(path)] if path
      raise if paths.empty?
      @data.each do |name, value|
        write!(name, value)
      end
    end

  private

    # If a method is missing ... ?
    #--
    # TODO: setting makes sense, but is the getter needed ?
    #++

    def method_missing(s, *a)
      name = s.to_s.chomp('=')
      case s.to_s
      when /\=$/
        self[name] = a.first
      else
        self[name]
      end
    end

    # Get a metadata +entry+, where entry is a pathname.
    # If it is a directory, will create a new FileStore object.

    def read!(entry)
      if entry.directory?
        data = FileStore.new(self, entry.basename)
      else
        text = entry.read.strip
        data = (/\A^---/ =~ text ? YAML.load(text) : text)
      end
      data
    end

    # Write entry to file system.
    #--
    # TODO: escape filename for file system if needed
    #++

    def write!(name, value, overwrite=true)
      filename = name # TODO
      dir = paths.find{ |dir| (dir + filename).exist? }
      if dir
        file = dir + filename
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
        file = paths.first + filename
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

    # List of available entries.

    def entries
      @_keys
    end

    # Convert to YAML.
    #  FIXME

    #def to_yaml
    #  @data.to_yaml
    #end

    # Return metadata in Hash form.

    def to_h
      load_soft!
      @data.dup
    end

    # M O D I F I C A T I O N

    # Update underlying data table.

    def update(other)
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

    # Like #update but does not update a value if it is *empty*.

    def mesh(other)
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

  end

end

