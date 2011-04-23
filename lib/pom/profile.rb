require 'fileutils'
require 'time'
require 'yaml'

#
#require 'pom/metadata'

require 'pom/core_ext'
require 'pom/version'
require 'pom/requires'
require 'pom/resources'

require 'pom/properties/main'
require 'pom/profile/infer'

module POM

  # Profile information cne be written in either pure YAML or a Ruby script.
  # A typical example of a YAML-based file might start out like:
  #
  #   ---
  #   name      : pom
  #   version   : 1.0.0
  #   date      : 2010-06-15
  #
  #   requires:
  #     - qed 2.3+ (test)
  #
  # In the implementation of the class, the #property method is used
  # to delegate attributes to an instance of Metadata. These are not
  # actually necessary becuase #method_missing would otherwise handle
  # them as well, but use of #property makes the code more explict
  # in intent and alos provides a minor improvement in effciency.
  #
  class Profile

    include Infer

    # TODO: probably change name of this
    CANONICAL_FILENAME = '.ruby'

    # Regular expression for matching valid email addresses.
    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    class << self
      # Initialize, but do not load form file.
      alias create new

      # Initialize and load file (if found).
      def new(root, data={})
        create(root, data).load!
      end
    end

    # Possible profile file names.
    def self.filename
      ['[Pp]rofile', 'PROFILE']
    end

    # The default file name.
    def self.default_filename
      'Profile'
    end

    #
    def self.default_sources
      ['[Pp]rofile', 'PROFILE', 'meta']
    end

    # Define a metadata property.
    def self.property(name)
      module_eval %{
        def #{name}(value=nil)
          self["#{name}"] = parse("#{name}", value) if value
          self["#{name}"] ||= default("#{name}")
        end
        def #{name}=(value)
          self["#{name}"] = parse("#{name}", value)
        end
      }
    end

    # Alias an accessor.
    def self.property_alias(name, original)
      alias_method name, original
      alias_method "#{name}=", "#{original}="
    end

    # New Profile object. To create a new Profile
    # the +root+ directory of the project and the +name+
    # of the project are required.
    def initialize(root, data={})
      @root = Pathname.new(root).expand_path

      @data = {}
      @data['spec_version'] = POM::VERSION

      #@file = data.delete(:file) || find || default_file

      data.each do |k,v|
        self[k] = v
      end

      ## only read .ruby if we have no Profile file to use
      #if file && file.exist?
      #  @metadata = Metadata.create(root, data)
      #else
      #  @metadata = Metadata.new(root, data)
      #end

      # for compatibility with Bundler
      @_source   = nil
      @_group    = []
      @_platform = []
    end

    #
    def find
      pattern = '{' + self.class.filename.join(',') + '}{,.yml,.yaml}'
      root.glob(pattern, :casefold).first
    end

    #
    def default_file
      root + self.class.default_filename
    end

    # Project root.
    attr :root

    # Returns Pathname to (read) file.
    attr :file

    # POM Metadatais extensible. If an attribute is assigned that is not
    # already defined by an attribute reader then an entry will be created
    # for it.
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /\=$/
        self[name] = args.first
      when /\!$/
        super(sym, *args)
      else
        if block_given? or args.size > 0
          super(sym, *args)
        else
          self[name]
        end
      end
    end

    ## The Profile class delegates to the Metadata class.
    #def method_missing(sym, *args)
    #  meth = sym.to_s
    #  name = meth.chomp('=').chomp('?')
    #  case meth
    #  when /\!$/
    #    super(sym, *args)
    #  else
    #    metadata.value(name, *args)
    #  end
    #end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if key?(name)
      return false
    end

    #
    Property.list.each do |prop|
      property prop.name
      prop.aliases do |a|
        property_alias a, prop.name
      end
    end

=begin
    # Project's <i>packaging name</i>. It can default to title downcased,
    # if not supplied.
    property :name


    # Version number.
    property :version

    # Date this version was released.
    property :date


    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    property :codename

    # Namespace for this program. This is only needed if it is not the default
    # of the +name+ capitalized and/or the toplevel namespace is not a module.
    # For example, +activerecord+  uses +ActiveRecord+ for it's namespace,
    # not Activerecord.
    property :namespace
=end

    # TODO: Integer-esque build number.
    #property :build_number

    # TODO: Integer-esque revison id from SCM.
    #property :scm_revision_id

=begin
    # Internal load paths.
    property :loadpath

    # Access to manifest list or file name.
    property :manifest

    # The SCM which the project is currently utilizing.
    property :scm

    # List of requirements.
    property :requires

    # List of packages with which this project cannot function.
    property :conflicts

    # List of packages that this package can replace (approx. same API).
    property :replaces

    # The Ruby engine and versions required by the project.
    property :engines

    # The post-installation message.
    property :message

    # Title of package (this defaults to project name capitalized).
    property :title

    # A one-line brief description.
    property :summary

    # Detailed description.
    property :description

    # Name of the user-account or master-project to which this project
    # belongs. The suite name defaults to the project name if no entry
    # is given. This is also aliased as #collection.
    property :suite

    # Organization.
    property :organization

    # Official contact for this project. This is typically
    # a name and email address.
    property :contact

    # The date the project was started.
    property :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    property :copyright

    # License, e.g. 'Apache 2.0'.
    property :licenses

    # List of authors.
    property :authors

    # List of maintainers.
    property :maintainers

    # Table of project URLs encapsulated in a Resources object.
    property :resources

    # Returns a Hash of +Type+ => +URI+ for SCM repository.
    property :repositories

    # (TODO: DEPRECATE?)
    property_alias :code,  :codename
    #property_alias :nick,     :codename
    #property_alias :moniker,  :nick
    #property_alias :monicker, :nick # because clowns are funny

    # Alias for #loadpath.
    property_alias :path         , :loadpath

    # Alias for #loadpath. This is the term used in gemspecs.
    property_alias :require_paths, :loadpath

    #
    property_alias :requirements, :requires
    property_alias :dependencies, :requires
    property_alias :gems        , :requires

    # The files of the project.
    #property_alias :files, :manifest

    # Alias for #message. This is the term used in gemspecs.
    property_alias :post_install_message, :message
=end

    # Designate a requirement.
    def gem(name, *args)
      opts = Hash == args.last ? args.pop : {}

      name, *cons = name.split(/\s+/)

      if md = /\((.*?)\)/.match(cons.last)
        cons.pop
        group = md[1].split(/\s+/)
        opts['group']   = group
      end

      opts['name']    = name
      opts['version'] = cons.join(' ') unless cons.empty?

      opts['source'] ||= @_source if @_source

      unless @_group.empty?
        opts['group'] ||= []
        opts['group'] += @_group
      end

      unless @_platform.empty?
        opts['platform'] ||= []
        opts['plarform'] += @_platform
      end

      requires << opts
    end

    # --- Bundler Gemfile Compatibility ---

    def source(source) #:yield:
      @_source = source
      yield
    ensure
      @_source = nil
    end

    # For use with defining dependencies with the +gem+ method.
    # This allows for compatibility with Bundler Gemfile.
    def group(*names) #:yield:
      @_group.concat names
      yield
    ensure
      names.each{@_group.pop}
    end

    # This allows for compatibility with Bundler Gemfile.
    def platform(*names) #:yield:
      @_platform.concat names
      yield
    ensure
      names.each{@_platform.pop}
    end

    # Alias for #platform.
    alias_method :platforms, :platform

    # FIXME: Do we need this?
    def path(path, options={}, source_options={}, &blk)
    end

    # This one sucks. Talk about favoring one SCM over another!
    # Handle submodules yourself like a real developer!
    def git(*)
      msg = "The `git` method is incompatible with POM.\n" /
            "Consider using submodules or an alternate tool\n" /
            "to manager vendored sources, and use the `path`\n" \
            "option instead."
      raise msg
    end

    # This one can blow!
    def gemspec(*)
      msg = "The `gemspec` method is incompatible with POM/.\n" /
            "POM will generate a gemspec from the Profile."
      raise msg
    end

    # --- End Bundler Gemfile Compatibility ---

    #
    def license(name)
      licenses << name.to_s
    end

    #
    #def license=(name)
    #  licenses = name
    #end

    #
    def resource(label, url)
      resources[label] = url
    end

    # Project's homepage as listed in the resources.
    def homepage
      resources.homepage
    end

    # Project's homepage as listed in the resources.
    def homepage=(url)
      resources.homepage = url
    end

    # Project's public repository as listed in the resources.
    #def repository
    #  repositories['public']
    #end

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

    # Version major number.
    def major
      version.major
    end

    # Version minor number.
    def minor
      version.minor
    end

    # Version patch number.
    def patch
      version.patch
    end

    # Version build number.
    def build
      version.build
    end

    # Current status (beta, alpha, pre, rc, etc.)
    def status
      version.status
    end

    # Set the date to the present moment.
    def now!
      self.date = Date.today
    end


    # Render "pretty" Profile. This uses an internal ERB template.
    # As such, it does not currently cover all properties, only the
    # most common.
    def render
      require 'erb'
      template_file = File.dirname(__FILE__) + '/profile/template.erb'
      template      = File.read(template_file)
      ERB.new(template,nil,'-').result(binding)
    end 

=begin
    # Like #save! but does a simple substitution on version and date
    # to ensure the layout of rest of the file is not altered.
    def save_version!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      now!  # update date
      if file.exist?
        yaml = File.read(file)
        yaml.sub!(/version(\s*):(\s*)(.*?)$/, 'version\1:\2' + version.to_s)
        yaml.sub!(/date(\s*):(\s*)(.*?)$/, 'date\1:\2' + date.strftime('%Y-%m-%d'))
        File.open(file, 'w'){ |f| f << yaml }
      else
        save!(file)
      end
    end
=end

    # Access metadate by +name+.
    # TODO: set instance variable from default if used
    def [](name)
      if prop = Property.find(name)
        @data[prop.name.to_s] || default(name)
      else
        @data[name.to_s] || default(name)
      end
    end

    #
    def []=(name, value)
      if prop = Property.find(name)
        @data[prop.name.to_s] = parse(name, value)
      else
        @data[name.to_s] = parse(name, value)
      end
    end

    #
    def key?(name)
      @data.key(name)
    end

    # Returns a list of metadata attributes.
    def attributes
      @data.keys
    end

    # Return the underlying Metadata object.
    #def to_metadata
    #  metadata
    #end

    # Convert to hash.
    # TODO: Use properties instead?
    def to_h
      h = {}
      @data.each do |k, v|
        h[k] = self[k]
      end
      h
    end

    #
    def to_data
      h = to_h
      h['version']   = h['version'].to_s
      h['requires']  = h['requires'].to_data  if h['requires']
      h['conflicts'] = h['conflicts'].to_data if h['conflicts']
      h['replaces']  = h['replaces'].to_data  if h['replaces']
      h['resources'] = h['resources'].to_data if h['resources']
      h
    end

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + codename.to_s + '"'      if codename
      s
    end

    # F I L E  H A N D L I N G

    # Load the +Profile+ data from sources.
    def load!(*sources)
      if sources.empty?
        sources = self.class.default_sources.map{ |src| File.join(root, src) }
      end

      sources.each do |src|
        if src = Dir[src].first
          if File.directory?(src)
            load_dir!(src)
          else
            load_file!(src)
          end
        end
      end

      self.name     = infer_name     unless name
      self.version  = infer_version  unless version
      self.manifest = infer_manifest unless manifest

      # TODO: validate
      #raise unless valid?

      return self
    end

    #
    def load_file!(file)
      if File.file?(file)
        text = File.read(file)
        if /\A---/ =~ text
          #text = ERB.new(text).result(Object.new.instance_eval{binding})
          data = YAML.load(text)
          data.each do |k,v|
            __send__("#{k}=", v)
          end
        else
          instance_eval(text, file, 0)  # TODO: Should we really do this here?
        end
      end
    end

    #
    def load_dir!(folder)
      # load meta directory.
      if File.directory?(folder)
        Dir[File.join(folder, '*')].each do |file|
          import!(file)
        end
      end
    end

    # Create new Metdata instance from metdata file.
    def load_canonical!
      file = root + CANONICAL_FILENAME
      if file.exist?
        data = YAML.load(File.new(file))
        data.each do |name, value|
          self[name] = value
        end
      end
      return self
    end

    # Import settings from another file.
    def import!(file)
      case File.extname(file)
      when '.yaml', '.yml'
        merge!(YAML.load(File.new(file)))
      else
        text = File.read(file).strip
        if /\A---/ =~ text
          merge!(YAML.load(text))
        else
          name = File.basename(file)
          self[name] = text.strip
        end
      end
    end

    # Import settings from another file.
    def import(file)
      case File.extname(file)
      when '.yaml', '.yml'
        merge!(YAML.load(File.new(file)))
      else
        text = File.read(file).strip
        if /\A---/ =~ text
          merge!(YAML.load(text))
        else
          name = File.basename(file)
          self[name] = text.strip
        end
      end
    end

    # Returns Pathname of Canonical file.
    def canonical_file
      root + CANONICAL_FILENAME
    end

    # Update the canonical file.
    def update!
      if canonical_file.exist?
        if file.mtime > canonical_file.mtime
          save!
        end
      else
        save!
      end
    end

    # Notice that +file+ does not default to +@file+.
    # The developers +Profile+ file is not saved, rather
    # the hidden cannonical format is.
    def save!(file=nil)
      file = file || canonical_file
      file = root + file if String === file
      File.open(file, 'w') do |f|
        f << to_data.to_yaml
      end
    end

    # Backup the cannonical file.
    def backup!(file=nil)
      file = file || FILENAME
      dir = root + BACKUP_DIRECTORY
      FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
      FileUtils.mkdir(dir) unless dir.directory?
      save!(dir + CANONICAL_FILENAME)
    end

    private

    #
    def default(name)
      if prop = Property.find(name)
        case default = prop.default
        when Proc
          instance_eval(&default)
        else
          default
        end
      else
        nil
      end
      #if respond_to?("default_#{name}")
      #  __send__("default_#{name}")
      #else
      #  nil
      #end
    end

    #
    def parse(name, value)
      if prop = Property.find(name)
        case parser = prop.parser
        when Proc
          #instance_exec(value, &parse)
          parser.call(value)
        else
          value
        end
      else
        value
      end
      #if respond_to?("parse_#{name}")
      #  value = __send__("parse_#{name}", value)
      #end
      #value
    end

  end

end
