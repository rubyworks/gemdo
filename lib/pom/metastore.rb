require 'pom/corext'
require 'pom/root'
require 'pom/metastore'

module POM

  # Metastore serves as the base class for the Metadata
  # class and the Metabuild class. It connects the file
  # system to the Ruby model.

  class Metastore

    # Like new but reads all metadata into memory.
    def self.load(root=Dir.pwd)
      new(root) #.load
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
    def self.alias_accessor(name, orig)
      alias_method(name, orig)
      alias_method("#{name}=", "#{orig}=")
    end

    # Project root directory.
    attr :root

    # Change the root location if +dir+.
    def root=(dir) 
      @root = Pathname.new(dir) if dir
    end

    # I N I T I A L I Z E

    # New Metastore object.
    #
    def initialize(root=nil)
      @root = Pathname.new(root) if root
      @data = {}

      initialize_defaults

      reload
    end

    #
    def reload
      if root
        stores.each do |store|
          load_data(root + store)
        end
      end
      self
    end

    private

    #
    def load_data(path)
      datadir = Pathname.new(path) #@root + dir
      return unless datadir.directory?
      datadir.glob('**/*').each do |file|
        #name = file.to_s.sub(datadir.to_s + '/', '').gsub('/','_') #.gsub('/','_')
        name  = path_to_name(file, datadir)
        #next if file.to_s.index(/[.]/)  # TODO: improve rejection filter
        self[name] = read(file)
      end
    end

    public

    # Load initialization values for a new project.
    # This is used by the 'pom init' command.
    def new_project
      new_project_defaults.each do |name, value|
        self[name] = value
      end
      home_config = ENV['XDG_CONFIG_HOME'] || '~/.config'
      store = stores.find{ |s| s[0,1] != '.' }  # not hidden
      path  = Pathname.new(File.join(home_config, 'pom', store))
      load_data(path)

      #default_entries = default_dir.glob('**/*')
      #default_entries.each do |path|
      #  name  = path_to_name(path, default_dir)
      #  #value = path.read
      #  defaults[name] = read(path)
      #end
      #defaults.each do |name, value|
      #  self[name] = value
      #end
    end

    # Subclasses can override this. It is used by #load_defaults.
    def new_project_defaults
      {}
    end

    # Get a metadata +entry+, where entry is a pathname.
    def read(entry)
      text = entry.read.strip
      data = (/\A^---/ =~ text ? YAML.load(text) : text)
    end

    # P E R S I S T E N C E

    public

    # Backup current metadata files to <tt>.cache/pom/</tt>.
    def backup!(chroot=nil)
      self.root = chroot
      cache = root + '.cache/pom/'
      FileUtils.mkdir_p(cache) unless File.exist?(cache)
      stores.each do |dir|
        if (root + dir).directory?
          FileUtils.cp_r(root + dir, cache)
        end
      end
      cache
    end

    # Save metadata to <tt>meta/</tt> directory (or <tt>.meta/</tt> if it is found).
    def save!(chroot=nil)
      self.root = chroot
      @data.each do |name,value|
        save_entry(name, value)
      end
    end

    # Fallback store.
    def fallback_store
      @fallback_store ||= root.glob('{'+stores+'}').last || Pathname.new(stores.last)
    end

    private

    # Save meta entry.
    def save_entry(name, value, overwrite=true)
      path = name.sub(/\_+/, '/')
      file = root.glob("{" + stores.join(',') + "}/#{path}").first
      if file
        if overwrite
          text  = file.read
          yaml  = /\A---/ =~ text
          value = value.to_yaml if yaml
          if text != value
            File.open(file, 'w'){ |f| f << value }
          end
        end
      else
        unless value.empty?
          path = fallback_store + path
          FileUtils.mkdir_p(path.parent) unless path.parent.exist?
          case value
          when String
            File.open(path, 'w'){ |f| f << value }
          else
            File.open(path, 'w'){ |f| f << value.to_yaml }
          end
        end
      end
    end

    # C O N V E R S I O N

    public

    # Convert to YAML.
    def to_yaml
      @data.to_yaml #super
    end

    # Return metadata in Hash form.
    def to_h
      @data.dup
    end

    # List of available entries.
    def keys
      @data.keys
    end

    # M O D I F I C A T I O N

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

    # S U P P O R T  M E T H O D S

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
    def path_to_name(path, prefix='')
      path = path.to_s
      path = path.sub(prefix.to_s.chomp('/') + '/', '')
      path = path.gsub('/', '_')
      path
    end

  end

  #
  class ValidationError < ArgumentError  # :nodoc:
  end

end

