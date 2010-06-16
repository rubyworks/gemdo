module POM

  # Base case for metadata yaml files.
  class YAMLStore

    #
    def self.filename
      ['.' + name.split('::').last.downcase]
    end

    #
    def self.find(root)
      pattern = '{' + filename.join(',') + '}{,.yml,.yaml}'
      root.glob(pattern, :casefold).first
    end

    #
    def self.attributes
      @attributes ||= []
    end

    #
    def self.defaults
      @defaults ||= {}
    end

    #
    def self.attr_accessor(name, default=nil, &block)
      attributes << name.to_sym
      defaults[name.to_sym] = default || block
      super(name)
    end

    #
    def initialize(root)
      @root = root

      @file = self.class.find(root)

      if @file && @file.exist?
        data = YAML.load(File.new(@file))
        data.each do |k,v|
          __send__("#{k}=", v)
        end
      end

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

    #
    attr :root

    #
    attr :file

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

    #
    def backup!
      if @file
        dir = @root + '.cache/pom'
        FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
        FileUtils.mkdir(dir) unless dir.directory?
        save!(dir + self.class.filename.first)
      end
    end

    #
    def save!(file=nil)
      file = file || @file || self.class.filename.first
      file = @root + file if String === file
      File.open(file, 'w') do |f|
        f << to_h.to_yaml
      end
    end

    # Convert to hash.
    def to_h
      h = {}
      self.class.attributes.each do |a|
        h[a.to_s] = __send__(a)
      end
      h
    end

    #
    def each(&block)
      to_h(&block)
    end

    #
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /=$/
        (class << self; self; end).class_eval do
          attr_accessor name
        end
        instance_variable_set("@#{name}", args.first)
      else
        super(sym, *args) if block_given? or args.size > 0
        nil
      end
    end

  end

end
