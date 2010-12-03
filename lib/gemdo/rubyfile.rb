require 'gemdo/rubyspec'

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
      ['Rubyfile', '.rubyfile']
    end

    #
    def initialize(root, data={})
      @root = Pathname.new(root)

      @file = data.delete(:file)    ||
              self.class.find(root) ||
              root + self.class.default_filename

      @data = data

      load!
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

    # Designate a requirement.
    def gem(name, version=nil, options={})
      @data['requires'] ||= []
      if version
        options['name']    = name
        options['version'] = version
        @data['requires'] << options
      else
        @data['requires'] << name
      end
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

    #
    def load!
      if file && file.exist?
        script = File.read(file)
        instance_eval(script, file)
      end
    end
  end

end
