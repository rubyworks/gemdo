require 'pom/yamlstore'

module POM

  #
  class Resources #< YAMLStore

    #
    ##def self.filename
    ##  ['.resources', 'RESOURCES']
    ##end

    # Offical project website.
    attr_accessor :homepage #home

    # Location of development site.
    attr_accessor :development  #work

    # Location of documentation.
    attr_accessor :documentation  #doc

    # Package distribution service webpage.
    attr_accessor :distribute

    # Downloadable packages.
    attr_accessor :download

    # Browse source code.
    attr_accessor :source

    # User discussion forum.
    attr_accessor :forum

    # Mailing list email or web address to online version.
    attr_accessor :mailinglist

    # Location of issue tracker.
    attr_accessor :issues

    # Location of support forum.
    attr_accessor :support

    # Location of API reference documentation.
    attr_accessor :reference

    # Location of wiki-wiki.
    attr_accessor :wiki

    # Resource to project blog.
    attr_accessor :blog

    # IRC channel
    attr_accessor :irc

    # Resource for central *public* repository, e.g.
    #   git://github.com/protuils/pom.git
    attr_accessor :repository  #repo

    #
    def initialize(table={})
      table.each do |k,v|
        instance_variable_set("@#{k}", v)
      end     
    end

  end

end

