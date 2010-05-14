class POM::Metadata

  def sites
    @data['sites'] ||= Sites.new(self, 'sites')
  end

  # Sites hold a project's collection of URLs.
  #
  # TODO: Try to standardize some of these names to one option.
  #
  class Sites < POM::FileStore

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

    # Location of API documentation.
    attr_accessor :api

    # Location of wiki-wiki.
    attr_accessor :wiki

    # Resource to project blog.
    attr_accessor :blog

    # IRC channel
    attr_accessor :irc

    # Resource for central *public* repository, e.g.
    #   git://github.com/protuils/pom.git
    attr_accessor :repository  #repo

  end

end

