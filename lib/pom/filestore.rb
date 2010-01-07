require 'pom/core_ext'
require 'pom/errors'

module POM

  # FileStore serves as the base class for the Metadata
  # class. It connects the file system to the POM model.

  class FileStore

    def self.registry
      @@registry ||= {}
    end

    #
    def self.inherited(base)
      registry[base.path.to_s] = base
    end

    #
    def self.path
      name.split('::').last.downcase
    end

    #
    def self.factory(path)
      name = File.basename(path)
      if registry.key?(name)
        registry[name].new(path)
      else
        new(path)
      end
    end

    #
    def self.attr_accessor(name)
      code = %{
        def #{name}     ; @data["#{name}"]     ; end
        def #{name}=(x) ; @data["#{name}"] = x ; end
      }
      eval code
    end

    #
    def self.alias_accessor(name, orig)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

  private

    #
    def initialize(directory=nil)
      @directory = Pathname.new(directory) if directory
      @data = {}
      initialize_defaults
    end

    #
    def initialize_defaults
    end

    # Subclasses can override this.
    def new_project_defaults
      {}
    end

  public

    #
    attr :directory

    #
    def hidden
      @hidden ||= directory.dirname + ".#{directory.basename}"
    end

    #
    def [](name)
      @data[name.to_s] ||= (
        file = directory + name.to_s
        if File.exist?(file)
          @data[name] = read!(file)
        end
      )
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

    #
    def load!(path=nil)
      if path     
        path.glob('*').each do |file|
          #next if file.to_s.index(/[.]/)  # TODO: rejection filter
          name = path_to_name(file, path)
          self[name] = read!(file)
        end
      else
        [hidden, directory].each{ |path| load!(path) }
      end
    end

    #
    def save!(path=nil)
      self.directory = Pathname.new(path) if path
      raise unless directory
      @data.each do |name, value|
        write!(name, value)
      end
    end

  private

    #
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
        data = FileStore.factory(entry)
      else
        text = entry.read.strip
        data = (/\A^---/ =~ text ? YAML.load(text) : text)
      end
    end

    #
    #def write!(name, value)
    #  file = directory + name.to_s
    #  #if File.exist?(file)
    #    File.open(file, 'w'){ |f| f << value }
    #  #end
    #end

    # Write entry to file system.
    #--
    # TODO: escape filename for file system if needed
    #++
    def write!(name, value, overwrite=true)
      filename = name
      file = [directory + filename, hidden + filename].find{ |pathname| pathname.exist? }
      if file
        if overwrite
          text  = file.read
          yaml  = /\A---/ =~ text
          value = value.to_yaml if yaml
          if text != value
            write_raw!(file, value)
          end
        end
      else
        unless value.empty?
          case value
          when String
            out = value
          else
            out = value.to_yaml
          end
          file = directory + filename
          write_raw!(file, out)
        end
      end
    end

    #
    def write_raw!(pathname, value)
      FileUtils.mkdir_p(pathname.parent) unless pathname.parent.exist?
      File.open(pathname, 'w'){ |f| f << value }
    end

    # S U P P O R T  M E T H O D S

    #
    def path_to_name(path, prefix='')
      path = path.to_s
      path = path.sub(prefix.to_s.chomp('/') + '/', '')
      #path = path.gsub('/', '_')
      path
    end

  public

    # C O N V E R S I O N

    # Convert to YAML.
    #  FIXME

    #def to_yaml
    #  @data.to_yaml
    #end

    # Return metadata in Hash form.

    def to_h
      @data.dup
    end

    # List of available entries.

    def keys
      @data.keys
    end

    # M O D I F I C A T I O N

    # Update underlying data table.

    def update(other)
      case other
      when Hash
        data = other
      when self.class #Metastore
        data = other.instance_eval{ @data }
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
      when self.class #Metastore
        data = other.instance_eval{ @data }
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

