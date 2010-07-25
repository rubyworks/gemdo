require 'pom/metafile'
require 'pom/resources'

module POM

  # Profile stores ancillary project metadata such
  # as title, summary, list of authors, etc. Profile
  # is the "mother load" of end-user information
  # about a project. It is also arbitraily extensible
  # so fields not strictly defined by this class
  # can also be provided.
  #
  class Profile < Metafile

    # The default file name to use for saving
    # a new PROFILE file.
    def self.default_filename
      '.ruby/profile'
    end

    # Possible project file names.
    def self.filename
      ['.ruby/profile', 'PROFILE']
    end

    # New Profile object. To create a new Profile
    # the +root+ directory of the project and the +name+
    # of the project are required.
    def initialize(root, name, opts={})
      @name = name
      super(root, opts)
    end

    ;; public

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr :name

    # Title of package (this defaults to project name capitalized).
    attr_accessor :title do
      name.capitalize if name
    end

    # A one-line brief description.
    attr_accessor :summary do
      d = description.to_s.strip
      i = d.index(/(\.|$)/)
      i = 69 if i > 69
      d[0..i]
    end

    # Detailed description.
    attr_accessor :description

    # Name of the user-account or master-project to which this project
    # belongs. The suite name defaults to the project name if no entry
    # is given. This is also aliased as #collection.
    attr_accessor :suite

    #
    alias_accessor :collection, :suite

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
    attr_accessor :authors do
      []
    end

    # Table of project URIs encapsulated in a Resources object.
    attr_accessor :resources do
      Resources.new
    end

    # Set project resources table with a Hash or another Resources object.
    def resources=(resources)
      self['resources'] = Resources.new(resources)
    end

    # Project's homepage as listed in the resources.
    def homepage
      resources.homepage
    end

    # Project's public repository as listed in the resources.
    def repository
      resources.repository
    end

    # Regular expression for matching valid email addresses.
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

    # Convert to hash.
    def to_h
      data = @data.dup
      data['resources'] = data['resources'].to_h
      data
    end

    # Profile is extensible. If a setting is assigned
    # that is not already defined an attribute accessor
    # will be created for it.
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /=$/
        self[name] = args.first
      else
        super(sym, *args) if block_given? or args.size > 0
        nil
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if self[name]
      return false
    end
  end

end

