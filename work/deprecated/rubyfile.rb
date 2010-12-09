require 'gemdo/spec'

module Gemdo

  # A Rubyfile is a script that is used to buld a Rubyspec.
  class Rubyfile

    #
    def self.attr_setter(name)
      define_method(name) do |value|
        @data[name.to_s] = value
      end
    end

    #
    def self.find(root)
      root = Pathname.new(root)
      pattern = '{' + filename.join(',') + '}{,.rb}'
      root.glob(pattern, :casefold).first
    end

    # The default file name to use for saving a new Rubyfile.
    def self.default_filename
      'Rubyfile'
    end

    # Standard file names for a Rubyfile. Notice that the file
    # can be visible or hidden.
    def self.filename
      ['Rubyfile', '.rubyfile', 'Gemfile']
    end

    #
    def initialize(root, data={})
      @root = Pathname.new(root)

      @file = data.delete(:file)    ||
              self.class.find(root) ||
              root + self.class.default_filename

      @data = data

      # for compatibility with Bundler
      @_source   = nil
      @_group    = []
      @_platform = []

      load!
    end

    #
    def load!
      if files.each do |file|
        if file.exist?
          script = File.read(file)
          if /^A---/ =~ script
            import YAML.load(script)
          else
            instance_eval(script, file)
          end
        end
      end
    end

    #
    def import(file)
      case File.extname(file)
      when '.yaml', '.yml'
        @data.merge!(YAML.load(File.new(file)))
      else
        text = File.read(file).strip
        if /\A---/ =~ text
          @data.merge!(YAML.load(text))
        else

        end
      end
    end

    #
    attr :file

    #
    attr_setter :name

    #
    attr_setter :version

    #
    attr_setter :date

    #
    def author(person)
      @data['authors'] ||= []
      @data['authors'] << person
    end

    #
    def manifest(file_or_array)
      case file_or_array
      when Array
        @data['manifest'] = file_or_array
      else
        list = File.readlines(file_or_array).to_a
        list = list.map{ |f| f.strip }
        list = list.reject{ |f| /^\#/ =~ f }
        list = list.reject{ |f| /^\s*$/ =~ f }
        @data['manifest'] = list
      end
    end

    #
    def requires(list)
      list.each{ |entry| gem entry }
    end
    alias_method :dependencies, :requires

    # Designate a requirement.
    def gem(name, *args)
      opts = Hash == args.last ? args.pop : {}

      name, *cons = name.split(/\s+/)

      if md = /\((.*?)\)/.match(cons.last)
        cons.pop
        group = md[1].split(/\s+/)
        opts['group']   = group
      end

      opts['name']    = name
      opts['version'] = cons.join(' ') unless cons.empty?

      opts['source'] ||= @_source if @_source

      unless @_group.empty?
        opts['group'] ||= []
        opts['group'] += @_group
      end

      unless @_platform.empty?
        opts['platform'] ||= []
        opts['plarform'] += @_platform
      end

      @data['requires'] ||= []
      @data['requires'] << opts
    end

    # --- Bundler Compatibility ??? ---

    def source(source) #:yield:
      @_source = source
      yield
    ensure
      @_source = nil
    end

    # For use with defining dependencies with the +gem+ method.
    # This allows for compatibility with Bundler Gemfile.
    def group(*names) #:yield:
      @_group.concat names
      yield
    ensure
      names.each{@_group.pop}
    end

    # This allows for compatibility with Bundler Gemfile.
    def platform(*names) #:yield:
      @_platform.concat names
      yield
    ensure
      names.each{@_platform.pop}
    end
    alias_method :platforms, :platform

    # ???
    def path(path, options={}, source_options={}, &blk)
    end

    # This one sucks. Talk about favoring one SCM over another!
    # Handle submodules yourself like a real developer!
    def git(*)
      msg = "The `git` method is incompatible with Gemdo.\n" /
            "Consider using submodules or an alternate tool\n" /
            "to manager vendored sources, and use the `path`\n" \
            "option instead."
      raise msg
    end

    # This one can blow!
    def gemspec(*)
      msg = "The `gemspec` method is incompatible with Gemdo/.\n" /
            "Gemdo will generate a gemspec from the Gemfile."
      raise msg
    end

    # --- End Bundler Compatibility ---

    #
    def resource(label, url)
      @data['resources'] ||= {}
      @data['resources'][label.to_s] = url
    end

    #
    def method_missing(name, *args, &block)
      super(name, *args, &block) if block
      if args.size > 1
        @data[name.to_s] = args
      else
        @data[name.to_s] = args.first
      end
    end

    #
    def to_rubyspec
      Rubyspec.new(@root, @data)
    end

  end

end
