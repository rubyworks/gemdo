require 'fileutils'
require 'time'
require 'yaml'

require 'dotruby'

require 'pom/core_ext'
#require 'pom/version'

require 'pom/profile/bundlerable'
require 'pom/profile/inference'

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

    include Bundlerable

    #
    DOTRUBY_FILENAME = '.ruby'

    #
    def self.load(root, *sources, &block)
      new(root, :defaults, *sources, &block)
    end

    #
    def self.default_sources
      ['[Pp]rofile', 'PROFILE', 'meta']
    end

    # Construct a new Profile object.
    # 
    # root    - root directory of the project
    # sources - list of sources to find project metadata
    # block   - block to be evaluated on Profile object
    #
    # If a block is given but the sources list is empty, than default file 
    # sources will not be loaded.
    #
    # Besides files, there are three special sources that can be
    # used -- :default, :gemspec and :canonical.
    #
    def initialize(root, *sources, &block)
      @root = Pathname.new(root).expand_path

      initialize_mixins

      options = sources.inject({}){ |h,s| h.merge!(s) if Hash === s; h }
      sources.reject!{ |s| Hash === s }

      @dotruby = DotRuby::Spec.new

      #@data = {}
      #@data['spec_version'] = POM::VERSION
      #@data['date'] = Time.now.strftime("%Y-%m-%d")

      #@file = data.delete(:file) || find || default_file

      @project = options[:project]

      @sources = sources

      if block
        block.call(self)
        if !sources.empty?
          load!(*sources)
        end
      else
        load!(*sources)
      end
    end

    #
    attr :dotruby

    #
    #def find
    #  pattern = '{' + self.class.filename.join(',') + '}{,.yml,.yaml}'
    #  root.glob(pattern, :casefold).first
    #end

    #
    #def default_file
    #  root + self.class.default_filename
    #end

    # Project root.
    attr_reader :root

    # Returns Pathname to (read) file.
    # TODO: change to sources and as an array
    attr :file

    # Access to POM Project object.
    def project
      @project ||= Project.new(root)
    end

    # Metadata is easily extensible. If an attribute is assigned that is not
    # explicitly defined by DotRuby Spec then it is stored in the extra store.
    def method_missing(sym, *args, &blk)
      meth = sym.to_s
      if dotruby.respond_to?(sym)
        dotruby.send(sym, *args, &blk)
      else
        name = meth.chomp('=')
        case meth
        when /\=$/
          dotruby.extra[name.to_s] = args.first
        when /\!$/
          super(sym, *args)
        else
          if block_given? or args.size > 0
            super(sym, *args)
          else
            dotruby.extra[name.to_s]
          end
        end
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if dotruby.respond_to?(name)
      return true if super(name)
      return true if key?(name)
      return false
    end

    # Convert to hash.
    #--
    # TODO: Should empty defaults be in the hash?
    #++
    def to_h
      dotruby.to_h
    end

    #
    def [](key)
      dotruby[key] || dotruby.extra[key]
    end

    #
    def []=(key, value)
      send("#{key}=", value)
    end

    #
    def key?(name)
      dotruby.key?(name) || dotruby.extra.key?(name.to_s)
    end

    # Does an entry have a value set?
    def value?(name)
      name = name.to_s
      return false unless key?(name)
      return false if self[name].nil?
      return true
    end

    ## Validate profile. It must at least have a name and a version.
    ## TODO: Loop through data and validate via Property.
    #def valid?
    #  return false if name.nil?
    #  return false if version.nil?
    #  return true
    #end

    # FIXME: Return a list of metadata attributes.
    def attributes
      @data.keys
    end

    # Merge Hash (or Hash-like) data into profile.
    def merge!(data)
      data.each do |k,v|
        self[k] = v
      end
    end

    # C O N V E N I E N C E  M E T H O D S

    # Primary license.
    def license(name=nil)
      if name
        self.license = name
      else
        if copryrights.first
          copyrights.first.license
        end
      end
    end

    # Set primary license.
    def license=(name)
      if copyrights.first
        copyrights.first.license = name.to_s
      else
        raise "set license after copyright"
      end
    end

    # Add a resource.
    def resource(label, url)
      resources[label] = url
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

    # R E P R E S E N T A I T O N S

    # Render "pretty" Profile. This uses an internal ERB template.
    # As such, it does not currently cover all properties, only the
    # most common.
    #
    # TODO: rename to #to_pretty_yaml or something like that.
    def render
      require 'erb'
      template_file = File.dirname(__FILE__) + '/profile/template.erb'
      template      = File.read(template_file)
      ERB.new(template,nil,'-').result(binding)
    end 

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + codename.to_s + '"'      if codename
      s
    end

    # F I L E  H A N D L I N G

    # Returns Array of the default file-based sources of project metadata.
    # These sources may be a file glob (mainly to handle variant capitalizations).
    def default_sources
      self.class.default_sources.map{ |src| File.join(root, src) }
    end

    # Returns Pathname for the canonical file.
    def dotruby_file
      root + DOTRUBY_FILENAME
    end

    # Load the +Profile+ data from sources.
    def load!(*sources)
      default = sources.delete(:default) || sources.delete(:defaults)

      if default || sources.empty?
        sources = default_sources + [:inference]
      end

      sources.each do |src|
        case src
        when :canonical, :dotruby
          load_dotruby!
        when :gemspec
          load_gemspec!
        when :inference
          inference = Inference.new(project)
          inference.apply(self)
        when String
          if src = Dir[src].first
            if File.directory?(src)
              load_dir!(src)
            else
              load_file!(src)
            end
          end
        else
          # ignore
        end
      end

      # TODO: validate
      #raise unless valid?

      return self
    end

    # Load in a file.
    def load_file!(file)
      if File.file?(file)
        yaml = %w{.yaml .yml}.include?(File.extname(file))
        text = File.read(file)
        if yaml or /\A---/ =~ text
          #text = ERB.new(text).result(Object.new.instance_eval{binding})
          data = YAML.load(text)
          data.each do |k,v|
            __send__("#{k}=", v)
          end
        else
          # TODO: Should we really do this here?
          instance_eval(text, file, 0)
        end
      end
    end

    # Import files in a given directory. This will only import files
    # that have a name corresponding to a DotRuby attributes, unless
    # the file is listed in a `.rubyextra` file within the directory.
    #
    # However, files with an extension of `.yml` or `.yaml` will be loaded
    # wholeclothe (not as a single attribute.)
    #
    # TODO: Subdirectories are simply omitted. Maybe do otherwise in future?
    def load_dir!(folder)
      # load meta directory.
      if File.directory?(folder)
        extra = []
        extra_file = File.join(folder, '.rubyextra')
        if File.exist?(extra_file)
          extra = File.read(extra_file).split("\n")
          extra = extra.collect{ |pattern| pattern.strip  }
          extra = extra.reject { |pattern| pattern.empty? }
          extra = extra.collect{ |pattern| Dir[File.join(folder, pattern)] }.flatten
        end
        files = Dir[File.join(folder, '*')]
        files.each do |file|
          next if File.directory?(file)
          next import!(file) if extra.include?(file)
          next import!(file) if %w{.yaml .yml}.include?(File.extname(file))
          next import!(file) if dotruby.key?(File.basename(file))
        end
      end
    end

    #
    def load_dotruby!
      file = dotruby_file
      if file.exist?
        data = YAML.load(File.new(file))
        data.each do |name, value|
          self[name] = value
        end
      end
      return self
    end

    # Import Gem::Specification from instance or file.
    #
    def load_gemspec!(gemspec=nil)
      case gemspec
      when ::Gem::Specification
        spec = gemspec
      else
        file = Dir[root + "{*,}.gemspec"].first
        return unless file
        text = File.read(file)
        if text =~ /\A---/
          spec = ::Gem::Specification.from_yaml(text)
        else
          spec = ::Gem::Specification.load(file)
        end
      end

      dotruby.import_gemspec(spec)
    end

    # Import setting(s) from another file.
    def import!(file)
      if File.directory?(file)
        # ...
      else
        case File.extname(file)
        when '.yaml', '.yml'
          merge!(YAML.load(File.new(file)))
        else
          text = File.read(file)
          if /\A---/ =~ text
            name = File.basename(file)
            self[name] = YAML.load(text)
          else
            name = File.basename(file)
            self[name] = text.strip
          end
        end
      end
    end

    # Import settings from another file.
    alias_method :import, :import!

# TODO: Move these to elsewhere?

    # Notice that +file+ does not default to +@file+.
    # The developers +Profile+ file is not saved, rather
    # the hidden cannonical format is.
    def save!(file=nil)
      file = file || dotruby_file
      dotruby.save!(file)
      return file
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

    # Backup the cannonical file.
    def backup!(file=nil)
      file = file || FILENAME
      dir = root + BACKUP_DIRECTORY
      FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
      FileUtils.mkdir(dir) unless dir.directory?
      save!(dir + DOTRUBY_FILENAME)
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

  end

  # For backwards compatibility.
  Metadata = Profile

end














    # Possible profile file names.
    #def self.filename
    #  ['[Pp]rofile', 'PROFILE']
    #end

    # The default file name.
    #def self.default_filename
    #  'Profile'
    #end


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


=begin
    # Define a metadata property.
    def self.property(name)
      module_eval %{
        def #{name}(value=nil)
          if value
            self["#{name}"] = parse("#{name}", value)
          end
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
=end

=begin
    # Project's <i>packaging name</i>. It can default to title downcased,
    # if not supplied.
    property :name

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
    # Access to manifest list or file name.
    property :manifest

    # The SCM which the project is currently utilizing.
    property :scm

    # List of packages that this package can replace (approx. same API).
    property :replaces

    # Official contact for this project. This is typically
    # a name and email address.
    property :contact

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    property :copyright

    # License, e.g. 'Apache 2.0'.
    property :licenses

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
    property_alias :gems        , :requires

    # The files of the project.
    #property_alias :files, :manifest

    #
    #def license=(name)
    #  licenses << name.to_s
    #end

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
=end

=begin
    # Convert to hash.
    #--
    # TODO: Should empty defaults be in the hash?
    #++
    def to_h
      h = {}
      props = Property.list.map{|prop| prop.name.to_s} | @data.keys
      props.each do |k|
        v = self[k]
        h[k] = v if v
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
=end

=begin
    private

    #
    def default(name)
      if prop = Property.find(name)
        value = prop.default
        case value
        when Proc
          instance_eval(&value)
        else
          value
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
=end

=begin
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
=end

