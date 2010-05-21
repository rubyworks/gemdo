require 'pom/yamlstore'

module POM

  # Use +Reqfile+.
  class Requirements < YAMLStore #class Requisites < MetaStore

    #
    def self.filename
      ['Reqfile']
    end

    #
    def initialize(root)
      @data = {}
      super(root)
    end

    #
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /=$/
        @data[name] = Needs.new(*args)
      else
        if block_given? or args.size > 0
          return super(sym, *args)
        else
          return @data[name]
        end
      end
    end

    # TODO: Good enough?
    def to_yaml
      @data.to_yaml
    end

  end

  # Needs are various types of dependencies.
  class Needs

    # What other packages *must* this package have in order to function.
    # This includes any requirements neccessary for installation.
    attr_accessor :requires

    # External requirements, outside of the normal packaging system.
    attr_accessor :externals

    # What other packages *should* be used with this package.
    attr_accessor :recommend

    # What other packages *could* be useful with this package.
    attr_accessor :suggest

    # With what other packages does this package conflict.
    attr_accessor :conflicts

    # What other packages does this package replace. This is very much
    # like #provides but expresses a closser relation. For instance
    # "libXML" has been replaced by "libXML2".
    attr_accessor :replaces

    # What other package(s) does this package provide the same dependency
    # fulfilment. For example, a package 'bar-plus' might fulfill the same
    # dependency criteria as package 'bar', so 'bar-plus' is said to
    # provide 'bar'.
    attr_accessor :provides

    # Abirtary point list, especially about what might be needed
    # to use or build or use this package that does not fit under
    # +requires+. This is strictly information for the end-user
    # to consider, eg. "Needs gcc 4.4+" or "Needs fast graphics card".
    attr_accessor :consider

    # Versions of Ruby supported/tested.
    attr_accessor :ruby

    #
    def initialize(data={})
      initialize_defaults
      data.each do |k,v|
        __send__("#{k}=", [v].flatten.compact)
      end
    end

    #
    def initialize_defaults
      @requires  = []
      @externals = []
      @recommend = []
      @suggest   = []
      @conflicts = []
      @replaces  = []
      @provides  = []
      @consider  = []
    end

  end

end

