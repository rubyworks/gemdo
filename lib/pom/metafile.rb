require 'pom/core_ext'
require 'erb'
require 'yaml'

module POM

  # Metafile serves as a base class for POM's YAML-formatted
  # metadata files.
  #
  class Metafile

    #
    def self.filename
      basename = name.split('::').last
      [basename.upcase, '.'+basename.downcase]
    end

    #
    def self.default_filename
      name.split('::').last.upcase + '.yml'
    end

    #
    def self.defaults
      @@defaults ||= {}
    end

    # Attributes are stored in a hash instead of instance variables.
    def self.property(name, &default)
      module_eval %{
        def #{name}(val=nil)
          self['#{name}'] = val if val
          self['#{name}']
        end
        def #{name}=(val)
          self['#{name}'] = val
        end
      }
      defaults[name.to_s] = default if default
    end

    # Alias an accessor.
    def self.property_alias(name, original)
      alias_method name, original
      alias_method "#{name}=", "#{original}="
    end

    #
    def defaults
      @@defaults
    end

    #
    #def self.attr_accessor(name, default=nil, &block)
    #  attributes << name.to_sym
    #  defaults[name.to_sym] = default || block
    #  super(name)
    #end

    class << self
      alias create new

      def new(root, data={})
        create(root, data).read!
      end
    end

    private

    #
    def initialize(root, data={})
      @root = Pathname.new(root).expand_path

      @file = data.delete(:file) || find || default_file

      @data = {}

      data.each do |k,v|
        self[k] = v
      end

      #initialize_defaults
    end

    #
    def find
      pattern = '{' + self.class.filename.join(',') + '}'
      root.glob(pattern, :casefold).first
    end

    #
    def default_file
      root + self.class.default_filename
    end

    public

    # Project's root pathname.
    attr :root

    # Metadata filename.
    attr :file

    #
    def [](name)
      name  = name.to_s
      value = @data[name]
      if !value and defaults[name]
        value = instance_eval(&defaults[name])
        @data[name] = value
      end
      value
    end

    #
    def []=(name, value)
      if respond_to?("parse_#{name}") 
        value = __send__("parse_#{name}", value)
      end
      @data[name.to_s] = value
    end

    #
    def key?(name)
      @data.key?(name.to_s)
    end

    #
    def merge!(hash)
      hash.each do |k,v|
        case v
        when Proc
          self[k] = instance_eval(&v)
        else
          self[k] = v
        end
      end
    end

    # Convert to hash.
    def to_h
      @data.dup
    end

    #
    def to_h
      h = {}
      @data.each{ |k,v| h[k.to_s] = v }
      h
    end

    # Iterate over each attribute.
    def each(&block)
      @data.each(&block)
    end

    # Returns +self+.
    #def read!
    #  if file && file.exist?
    #    text = File.read(file)
    #    text = ERB.new(text).result(Object.new.instance_eval{binding})
    #    data = YAML.load(text)
    #    data.each do |k,v|
    #      __send__("#{k}=", v)
    #    end
    #  end
    #  return self
    #end

    # Read the file.
    #
    # Returns +self+.
    def read!
      if file && file.exist?
        text = File.read(file)
        if /\A---/ =~ text
          #text = ERB.new(text).result(Object.new.instance_eval{binding})
          data = YAML.load(text)
          data.each do |k,v|
            __send__("#{k}=", v)
          end
        else
          instance_eval(text, file, 0)
        end
      end
      return self
    end

    #
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      File.open(file, 'w') do |f|
        f << to_h.to_yaml
      end
    end

    #
    def backup!
      if @file
        dir = @root + BACKUP_DIRECTORY
        FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
        FileUtils.mkdir(dir) unless dir.directory?
        save!(dir + self.class.filename.first)
      end
    end

  end

end
