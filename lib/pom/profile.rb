require 'pom/yamlstore'
require 'pom/resources'

module POM

  #
  class Profile < YAMLStore

    #
    def self.filename
      ['PROFILE', 'Profile', '.profile']
    end

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr_accessor :name

    # Title of packa '.profile'ge (this defaults to project name capitalized).
    attr_accessor :title do
      name.to_s.capitalize
    end

    # A one-line brief description.
    attr_accessor :summary do
      if description
        i = description.index(/(\.|$)/)
        i = 69 if i > 69
        description.to_s[0..i]
      end
    end

    # Detailed description.
    attr_accessor :description

    # Name of the user-account or master-project to which this project belongs.
    # The suite name defaults to the project name if no entry is given.
    # This is also aliased as #collection.
    attr_accessor :suite

    #
    attr_accessor :collection do
      suite
    end

    # Contact can be any sort of resource that is intended
    # to be the end-users initial point of contact. It could
    # be the url to a mailing list, or a url to a forum, or the
    # email address of the maintainer, etc.
    attr_accessor :contact

    # Maintainer. This is the package maintainers name and
    # optionally their email addresses, eg. "Trans <trans@foo.com>".
    attr_accessor :maintainer

    # The date the project was started.
    attr_accessor :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright

    # License.
    attr_accessor :license

    # List of authors.
    attr_accessor :authors, []

    #
    def resources
      @resources ||= Resources.new
    end

    #
    def resources=(resources)
      case resources
      when Resources
        @resources = resources
      else
        @resources = Resources.new(resources)
      end
    end

    #
    def homepage
      resources.homepage
    end

    #
    def repository
      resources.repository
    end

  end

end
