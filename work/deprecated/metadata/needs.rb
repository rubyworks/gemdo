class POM::Metadata

  def needs
    @data['needs'] ||= Needs.new(self, 'needs')
  end

  # Needs holds a project's collection of dependencies.
  #
  class Needs < POM::FileStore

    ##
    # What other packages *must* this package have in order to function.
    # This includes any requirements neccessary for installation.
    # :attr_accessor: requries
    attr_accessor :requires, :default=>[]

    ##
    # External requirements, outside of the normal packaging system.
    # :attr_accessor: externals
    attr_accessor :externals, :default=>[]

    ##
    # What other packages *should* be used with this package.
    # :attr_accessor: recommend
    attr_accessor :recommend, :default=>[]

    ##
    # What other packages *could* be useful with this package.
    # :attr_accessor: suggest
    attr_accessor :suggest, :default=>[]

    ##
    # With what other packages does this package conflict.
    # :attr_accessor: conflicts
    attr_accessor :conflicts, :default=>[]

    ##
    # What other packages does this package replace. This is very much like #provides
    # but expresses a closser relation. For instance "libXML" has been replaced by "libXML2".
    # :attr_accessor: replaces
    attr_accessor :replaces, :default=>[]

    ##
    # What other package(s) does this package provide the same dependency fulfilment.
    # For example, a package 'bar-plus' might fulfill the same dependency criteria
    # as package 'bar', so 'bar-plus' is said to provide 'bar'.
    # :attr_accessor: provides
    attr_accessor :provides, :default=>[]

  end

end

