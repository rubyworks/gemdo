#require 'pom/version_file'
#require 'pom/version_helper'
require 'fileutils'
require 'time'
require 'pom/version'
require 'pom/metafile'
require 'pom/requires'
require 'pom/resources'

module POM

  # The Profile class encapsulates project metadata such as title, summary,
  # list of authors, etc. It is also arbitraily extensible so fields not 
  # strictly defined by this class can also be provided.
  #
  # The Profile class encapsulates essential information for packaging and
  # library management. This information will can derive from a YAML
  # document. A typical example will look like:
  #
  #   ---
  #   name      : pom
  #   version   : 1.0.0
  #   date      : 2010-06-15
  #
  #   requires:
  #     - qed 2.3+ (test)
  #
  # etc.
  #
  # Or an exetended form of Bundler's Ruby format.

  class Profile < Metafile

    require 'pom/profile/infer'

    include Infer
    #include VersionHelper

    BACKUP_DIRECTORY = '.cache/pom'

    #
    def self.find(root)
      root = Pathname.new(root)
      pattern = '{' + filename.join(',') + '}'
      root.glob(pattern, :casefold).first
    end

    # The default file name to use for saving a new PROFILE.
    def self.default_filename
      'Profile'
    end

    # Possible profile file names.
    def self.filename
      ['[Pp]rofile', 'PROFILE'] #, 'Gemfile']
    end

    # New Profile object. To create a new Profile
    # the +root+ directory of the project and the +name+
    # of the project are required.
    def initialize(root, data={})
      super(root, data)

      @data['loadpath']  = ['lib']
      @data['requires']  = []
      @data['conflicts'] = []
      @data['replaces']  = []

      # for compatibility with Bundler
      @_source   = nil
      @_group    = []
      @_platform = []
    end

    # Project root.
    attr :root

    # Get PACKAGE file path (if available).
    attr_accessor :file

    #
    def import(file)
      case File.extname(file)
      when '.yaml', '.yml'
        @data.merge!(YAML.load(File.new(file)))
      else
        text = File.read(file).strip
        if /\A---/ =~ text
          @data.merge!(YAML.load(text))
        else

        end
      end
    end


    # Project's <i>packaging name</i>. It can default to title downcased,
    # if not supplied.
    property :name do
      title.downcase if title
    end

    # Version number.
    property :version

    # Date this version was released.
    property :date

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    property :codename

    #property_alias :moniker,  :nick
    #property_alias :monicker, :nick # because clowns are funny

    # Namespace for this program. This is only needed if it is not the default
    # of the +name+ capitalized and/or the toplevel namespace is not a module.
    # For example, +activerecord+  uses +ActiveRecord+ for it's namespace,
    # not Activerecord.
    property :namespace

    # TODO: Integer-esque build number.
    #property :no

    # TODO: Integer-esque revison id from SCM.
    #property :id

    # Internal load paths.
    property :loadpath

    # Access to manifest list or file name.
    property :manifest


    # List of requirements.
    property :requires

    #
    property :conflicts

    #
    property :replaces


    # Title of package (this defaults to project name capitalized).
    property :title do
      name.to_s.capitalize
    end

    # A one-line brief description.
    property :summary do
      d = description.to_s.strip
      i = d.index(/(\.|$)/)
      i = 69 if i > 69
      d[0..i]
    end

    # Detailed description.
    property :description

    # Name of the user-account or master-project to which this project
    # belongs. The suite name defaults to the project name if no entry
    # is given. This is also aliased as #collection.
    property :suite

    # Organization.
    property :organization do
      suite
    end

    # Official contact for this project. This is typically
    # a name and email address.
    property :contact

    # The date the project was started.
    property :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    property :copyright

    # License.
    property :license

    # List of authors.
    property :authors do
      []
    end

    # Table of project URIs encapsulated in a Resources object.
    property :resources do
      Resources.new
    end


    # Short name for #version. (TODO: DEPRECATE?)
    property_alias :vers,  :version

    #
    property_alias :released,  :date

    #
    property_alias :release_date, :date

    #
    property_alias :code,  :codename

    #
    property_alias :path, :loadpath

    #
    property_alias :requirements, :requires
    property_alias :dependencies, :requires
    property_alias :gems        , :requires


    #
    def parse_version(number)
      VersionNumber.new(number)
    end

    # Returns a Time instance representing the release date.
    def parse_date(val)
      case val
      when Time, Date, DateTime
        val
      else
        Time.parse(val) if val
      end
    end

    # Returns a Ruby formatted namespace.
    def parse_namespace(ns)
      case ns
      when /^class/, /^module/
        ns.strip
      else
        "module #{ns.strip}"
      end
    end

    # 
    def parse_loadpath(path)
      case path
      when NilClass
        ['lib']
      when String
        path.split(/[,:;\ ]/)
      else
        path.to_a
      end
    end

    # Set manifest list or file name.
    def parese_manifest(file_or_array)
      case file_or_array
      when Array
        file_or_array
      else
        list = File.readlines(file_or_array).to_a
        list = list.map{ |f| f.strip }
        list = list.reject{ |f| /^\#/ =~ f }
        list = list.reject{ |f| /^\s*$/ =~ f }
        list
      end
    end

    #
    def parse_requires(list)
      PackageList.new(list)
    end

    #
    def parse_conflicts(list)
      PackageList.new(list)
    end

    #
    def parse_replaces(list)
      PackageList.new(list)
    end

    # Set project resources table with a Hash or another Resources object.
    def parse_resources(resources)
      Resources.new(resources)
    end


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

      @data['requires'] ||= []
      @data['requires'] << opts
    end

    # --- Bundler Compatibility ??? ---

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

    alias_method :platforms, :platform

    # ???
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
            "POM will generate a gemspec from the Gemfile."
      raise msg
    end

    # --- End Bundler Compatibility ---


    #
    def resource(label, url)
      #self['resources'] ||= {}
      self['resources'][label.to_s] = url
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
    # TODO: cahnge this to a list of repos. ?
    #def repository
    #  resources.repository
    #end

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

    #
    def major ; version.major ; end

    #
    def minor ; version.minor ; end

    #
    def patch ; version.patch ; end

    #
    def build ; version.build ; end

    # Current status (beta, alpha, pre, rc, etc.)
    def status
      if md = /(\w+)/.match(build.to_s)
        md[1].to_sym
      end
    end

    # Set the date to the present moment.
    def now!
      self[:date] = Date.today
    end

    # Convert to hash.
    def to_h
      data = super
      data['resources'] = data['resources'].to_h
      data
    end

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + codename.to_s + '"'      if codename
      s
    end

=begin
    #
    def yaml
      s = []
      s << "name    : #{name}"
      s << "date    : #{date.strftime('%Y-%m-%d')}"
      s << "version : #{version}"
      s << "codename: #{codename}" if codename
      s << "loadpath: #{loadpath}" if loadpath
      s << ""
      s << yaml_list('requires' , requires)
      s << yaml_list('replaces' , replaces)
      s << yaml_list('conflicts', conflicts)
      s.compact.join("\n")
    end

    #
    def yaml_list(name, list)
      return nil if list.empty?
      s = "\n#{name}:"
      list.each do |x|
        s << "\n- " + x.yaml.tabto(2)
      end
      s + "\n"
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      now!  # update date
      File.open(file, 'w'){ |f| f << yaml }
    end
=end

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

    # Backup the package file. This is used when updating the file.
    def backup!
      if file
        dir = root + BACKUP_DIRECTORY
        FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
        FileUtils.mkdir(dir) unless dir.directory?
        save!(dir + self.class.filename.first)
      end
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
        self[name] #nil
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if key?(name)
      return false
    end

=begin
    #
    def parse_release_stamp(text)
      release = {}
      # version
      if md = /\b(\d+\.\d.*?)\s/.match(text)
        release[:vers] = md[1]
      end
      # date
      if md = /\b(\d+\-\d.*?)\s/.match(text)
        release[:date] = md[1]
      end
      # nickname
      if md = /\"(.*?)\"/.match(text)
        release[:nick] = md[1]
      end
      # loadpath
      test.scan(/\s(\S+)\/\s/) do |m|
        release[:path] ||= []
        release[:path] << m
      end
      release
    end
=end

=begin
    # Save package information as Ruby source code.
    #
    #   module Foo
    #     VERSION  = "1.0.0"
    #     RELEASED = "2010-10-01"
    #     CODENAME = "Fussy Foo"
    #   end
    #
    # NOTE: This is not actually needed, as I exmplain in a recent
    # blog post. But we will leave it here for the time being.
    #
    # TODO: Improve upon this, allow selectable fields.
    def save_as_ruby(file)
      if File.exist?(file)
        text = File.read(file)
        save_as_ruby_sub!(text, :version, 'VERSION')
        save_as_ruby_sub!(text, :released, 'RELEASED', 'DATE')
        save_as_ruby_sub!(text, :codename, 'CODENAME')
      else
        t = []
        t << %[module #{codename}]
        t << %[  VERSION  = "#{version}"]
        t << %[  RELEASE  = "#{release}"]
        t << %[  CODENAME = "#{codename}"]
        t << %[end]
        text = t.join("\n")
      end
      File.open(file, 'w'){ |f| f << text }
    end

    #
    def save_as_ruby_sub!(text, field, *patterns)
      patterns = patterns.join('|')
      text.sub!(/(#{patterns}\s*)=\s*(.*?)(?!\s*\#?|$)/, '\1=' + __send__(field))
    end
=end

  end

end

