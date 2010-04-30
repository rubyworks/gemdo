class POM::Metadata

  def resources
    @data['resources'] ||= Resources.new(self, 'resources')
  end

  #
  class Resources < POM::FileStore

    # Offical project website.
    attr_accessor :homepage

    # Location of documentation.
    attr_accessor :documenation

    # Location of development site.
    attr_accessor :development

    # Downloadable packages.
    attr_accessor :download

    # Browse source code.
    attr_accessor :source

    # Discussion forum.
    attr_accessor :forum

    # Mailing list email or web address.
    attr_accessor :mailinglist

    # Location of wiki-wiki.
    attr_accessor :wiki

    # Location of issue tracker.
    attr_accessor :issues

    # Resource to project blog.
    attr_accessor :blog

    # Resource to central *public* repository, e.g.
    #
    #   git://github.com/protuils/pom.git
    #
    attr_accessor :repository


    # D E F A U L T S

    #
    #def initialize_defaults
    #  @data = {}
    #  @data['unixname'] = parent.suite
    #end

    #default_value(:unixname){ parent.suite }

    # S P E C I A L  S E T T E R S

    #
    #def groupid=(id)
    #  raise ValidationError unless /\d+/ =~ id
    #  @data['groupid'] = id
    #end

  end

end

