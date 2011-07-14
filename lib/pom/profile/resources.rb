module POM

  # The Resource class models a table of project
  # releated URIs. Each entry has a name and URI.
  # The class is Enumerable so each entry can
  # be iterated over, much like a hash.
  #
  # The class also recognizes common entry names
  # and aliases, which can be accessed via method
  # calls.
  # 
  # TODO: Consider if this should instead be an
  # associative array or [type, url]. Could there
  # not be more than one url for a given type?

  class Resources
    include Enumerable

    # Valid URL regular expression.
    URL = /^(\w+)\:\/\/\S+$/

    @key_aliases = {}

    #
    def self.key_aliases
      @key_aliases
    end

    #
    def self.attr_accessor name, *aliases
      code = []
      ([name] + aliases).each do |method|
        key_aliases[method.to_sym] = name.to_sym
        code << "def #{method}"
        code << "  self['#{name}']"
        code << "end"
        code << "def #{method}=(val)"
        code << "  self['#{name}'] = val"
        code << "end"
      end
      module_eval code.join("\n") 
    end

    # New Resources object. The initializer can
    # take a hash of name to URL.
    def initialize(data={})
      @table = {}

      data = {} if data.nil?

      data.each do |key, url|
        self[key] = url
      end
    end

    #
    def key_index(key)
      key = key.to_sym
      self.class.key_aliases[key] || key
    end

    #
    def [](key)
      @table[key_index(key)]
    end

    #
    def []=(key, url)
      raise ArgumentError, "Not a valid URL - `#{url}' for `#{key}'" unless URL =~ url
      @table[key_index(key)] = url
    end

    # Offical project website.
    attr_accessor :home, :homepage

    # Location of development site.
    attr_accessor :work, :dev, :development

    # Package distribution service webpage.
    attr_accessor :gem, :ditro, :distributor

    # Location to downloadable package(s).
    attr_accessor :download

    # Browse source code.
    attr_accessor :code, :source, :source_code

    # User discussion forum.
    attr_accessor :forum

    # Mailing list email or web address to online version.
    attr_accessor :mail, :email, :mailinglist

    # Location of issue tracker.
    attr_accessor :bugs, :issues

    # Location of support forum.
    attr_accessor :support

    # Location of documentation.
    attr_accessor :docs, :documentation, :doc

    # Location of API reference documentation.
    attr_accessor :api, :reference, :system_guide

    # Location of wiki.
    attr_accessor :wiki, :user_guide

    # Resource to project blog.
    attr_accessor :blog, :weblog

    # IRC channel
    attr_accessor :irc, :chat

    # Convert to Hash by duplicating the underlying
    # hash table.
    def to_h
      @table.dup
    end

    #
    def to_data
      h = {}
      to_h.each do |k,v|
        h[k.to_s] = v
      end
      return h
    end

    #
    def empty?
      @table.empty?
    end

    # Iterate over each enty, including aliases.
    def each(&block)
      @table.each(&block)
    end

    # The size of the table, including aliases.
    def size
      @table.size
    end

    #
    def inspect
      @table.inspect
    end

    #
    def merge!(res)
      res.each do |key, url|
        self[key] = url
      end
    end

    # If a method is missing and it is a setter method
    # (ending in '=') then a new entry by that name
    # will be added to the table. If a plain method
    # then the name will be looked for in the table.
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /=$/
        self[name] = args.first
      else
        super(sym, *args) if block_given? or args.size > 0
        self[name]
      end
    end

  end

end

