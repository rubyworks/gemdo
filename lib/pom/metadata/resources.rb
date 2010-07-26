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
  # How aliases work in this class is unique. When
  # a recognized name is assigned an URI, all it's
  # aliases are assigned the URI as well. Therefore
  # when iterating over the entries there will be
  # duplicate URIs under the various names.
  #
  #   Resources.new(:home=>'http://foo.com').to_h
  #   #=> {:home=>'http://foo.com', :homepage=>'http://foo.com'}
  #
  class Resources

    include Enumerable

    # Special accessors disperse access over multiple hash entries.
    def self.attr_accessor(*names)
      code = []
      names.each do |name|
        code << "def #{name}"
        code << "  @table['#{name}']"
        code << "end"
        code << "def #{name}=(val)"
        names.each do |n|
          code << "  @table['#{n}'] = val"
        end
        code << "end"
      end
      module_eval code.join("\n")
    end

    # New Resources object. The initializer can
    # take a hash of name to URI settings.
    def initialize(table={})
      @table = {}
      table.each{ |k,v| __send__("#{k}=", v) }
    end

    # Offical project website.
    attr_accessor :home, :homepage

    # Location of development site.
    attr_accessor :dev, :development, :work

    # Package distribution service webpage.
    attr_accessor :distributor

    # Location to downloadable package(s).
    attr_accessor :download

    # Browse source code.
    attr_accessor :code, :source

    # User discussion forum.
    attr_accessor :forum

    # Mailing list email or web address to online version.
    attr_accessor :mail, :email, :mailinglist

    # Location of issue tracker.
    attr_accessor :issues, :bugs

    # Location of support forum.
    attr_accessor :support

    # Location of documentation.
    attr_accessor :doc, :docs, :documentation

    # Location of API reference documentation.
    attr_accessor :api, :reference, :system_guide

    # Location of wiki.
    attr_accessor :wiki, :user_guide

    # Resource to project blog.
    attr_accessor :blog, :weblog

    # IRC channel
    attr_accessor :irc

    # Resource for central *public* repository, e.g.
    # `git://github.com/protuils/pom.git`.
    attr_accessor :repo, :repository

    # Convert to Hash by duplicating the underlying
    # hash table.
    def to_h
      @table.dup
    end

    # Iterate over each enty, including aliases.
    def each(&block)
      @table.each(&block)
    end

    # The size of the table, including aliases.
    def size
      @table.size
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
        @table[name] = args.first
      else
        super(sym, *args) if block_given? or args.size > 0
        nil
      end
    end

  end

end

