require 'gemdo/core_ext'
require 'erb'
require 'yaml'

module Gemdo

  # Where in project to store backups.
  BACKUP_DIRECTORY = '.cache/gemdo'

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
    def self.find(root)
      root = Pathname.new(root)
      pattern = '{' + filename.join(',') + '}{.yml,.yaml,}'
      root.glob(pattern, :casefold).first
    end

    #
    def self.defaults
      @defaults ||= {}
    end

    # Attributes are stored in a hash instead of instance variables.
    def self.attr_reader(name, &default)
      module_eval %{
        def #{name}; self['#{name}'] ; end
      }
      defaults[name] = default if default
    end

    # Attributes are stored in a hash instead of instance variables.
    def self.attr_accessor(name, &default)
      module_eval %{
        def #{name}; self['#{name}'] ; end
        def #{name}=(val); self['#{name}'] = val; end
      }
      defaults[name] = default if default
    end

    # Alias an accessor.
    def self.alias_accessor(name, original)
      alias_method name, original
      alias_method "#{name}=", "#{original}="
    end

    #
    #def self.attr_accessor(name, default=nil, &block)
    #  attributes << name.to_sym
    #  defaults[name.to_sym] = default || block
    #  super(name)
    #end

    ;; private

    #
    def initialize(root, data={})
      @root = Pathname.new(root)
      @file = data.delete(:file)    ||
              self.class.find(root) ||
              root + self.class.default_filename
      @data = data.inject({}){|h,(k,v)| h[k.to_s] = v; h}

      read!

      initialize_defaults
    end

    #
    def initialize_defaults
      self.class.defaults.each do |k,v|
        next if __send__("#{k}")
        case v
        when Proc
          __send__("#{k}=", instance_eval(&v))
        else
          __send__("#{k}=", v)
        end
      end
    end

    ;; public

    # Project's root pathname.
    attr :root

    # Metadata filename.
    attr :file

    #
    def [](name)
      @data[name.to_s]
    end

    #
    def []=(name, value)
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
          __send__("#{k}=", instance_eval(&v))
        else
          __send__("#{k}=", v)
        end
      end
    end

    # Convert to hash.
    def to_h
      @data.dup
    end

    #
    def each(&block)
      @data.each(&block)
    end

    #
    def read!
      if file && file.exist?
        text = File.read(file)
        text = ERB.new(text).result(Object.new.instance_eval{binding})
        data = YAML.load(text)
        data.each do |k,v|
          __send__("#{k}=", v)
        end
      end
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
