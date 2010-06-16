require 'pom/yamlstore'
require 'pom/resources'

module POM

  #
  class Profile < YAMLStore

    #
    def self.filename
      ['PROFILE']
    end

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    #attr_accessor :name

    # Title of package (this defaults to project name capitalized).
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

    # Official contact for this project. This is typically
    # a name and email address.
    attr_accessor :contact

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

    #
    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    # Contact's email address.
    def email
      if md = RE_EMAIL.match(contact.to_s)
        md[0]
      else
        nil
      end
    end

    # Returns the first entry in the authors list.
    def author
      authors.first
    end

  end

end
