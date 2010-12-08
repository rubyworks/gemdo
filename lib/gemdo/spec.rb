require 'fileutils'
require 'time'
require 'gemdo/metafile'
require 'gemdo/resources'
require 'gemdo/version'
require 'gemdo/requires'

module Gemdo

  #
  class Rubyspec < Metafile  #Profile < Metafile

    BACKUP_DIRECTORY = '.cache/gemdo'

    #
    def self.find(root)
      root = Pathname.new(root)
      pattern = '{,meta/}{' + filename.join(',') + '}{.yml,.yaml,}'
      root.glob(pattern, :casefold).first
    end

    #
    #include VersionHelper

    # The default file name to use for saving a new RubySpec.
    def self.default_filename
      '.rubyspec'
    end

    # Possible package file names.
    def self.filename
      ['.rubyspec'] #, 'rubyspec', 'Rubyspec', 'RubySpec', 'RUBYSPEC']
    end

=begin
    # New Profile object. To create a new Profile
    # the +root+ directory of the project and the +name+
    # of the project are required.
    def initialize(root, data={})
      @name = data.delete(:name) || data.delete('name')
      super(root, data)
      initialize_defaults
      data.each{ |k,v| __send__("#{k}=", v) }
    end
=end

    #
    def initialize(root, data={})
      @root = Pathname.new(root)
      super(root, data)
      initialize_defaults
      data.each{ |k,v| __send__("#{k}=", v) }
      #read!
    end

    #
    #def initialize_defaults
    #  @file = self.class.find(root) || root + self.class.default_filename
    #  @data['loadpath']  = ['lib']
    #  @data['requires']  = []
    #  @data['conflicts'] = []
    #  @data['replaces']  = []
    #end

    # Project root.
    attr :root

    # Get PACKAGE file path (if available).
    def file
      @file
    end

    # Set PACKAGE filepath.
    def file=(file)
      @file = file
    end

    # Project's <i>package name</i>. This actually comes from package,
    # but if provided here, can set the default for title.
    def name
      @name
    end

    # Name of package.
    def name
      self['name']
    end

    # Set name of package.
    def name=(name)
      self['name'] = name
    end

    # Version number.
    def version
      self['version']
    end

    #
    def version=(raw)
      self['version'] = VersionNumber.new(raw)
    end

    # Short name for #version.
    alias_method :vers,  :version
    alias_method :vers=, :version=

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

    # Date this version was released.
    def date
      self['date']
    end

    # Set release date.
    def date=(val)
      case val
      when Time, Date, DateTime
        self['date'] = val
      else
        self['date'] = Time.parse(val) if val
      end
    end

    #
    alias_method :released,  :date
    alias_method :released=, :date=

    #
    alias_method :release_date, :date

    # Set the date to the present moment.
    def now!
      self['date'] = Date.today
    end

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    def codename
      self['codename']
    end

    #
    def codename=(codename)
      self['codename']=codename
    end

    #
    alias_method :code,  :codename
    alias_method :code=, :codename=

    #alias_method :moniker,  :nick
    #alias_method :monicker, :nick # because clowns are funny

    # Namespace for this program. This is only needed if it is not the default
    # of the +name+ capitalized and/or the toplevel namespace is not a module.
    # For example, +activerecord+  uses +ActiveRecord+ for it's namespace,
    # not Activerecord.
    def namespace
      self['namespace']
    end

    # Set namespace.
    def namespace=(ns)
      case ns
      when /^class/, /^module/
        self['namespace'] = ns.strip
      else
        self['namespace'] = "module #{ns.strip}"
      end
    end

    # TODO: Integer-esque build number.
    #attr_accessor :no

    # TODO: Integer-esque revison id from SCM.
    #attr_accessor :id

    # Internal load paths.
    def loadpath
      self['loadpath']
    end

    #
    def loadpath=(path)
      case path
      when NilClass
        self['loadpath'] = ['lib']
      when String
        self['loadpath'] = path.split(/[,:;\ ]/)
      else
        self['loadpath'] = path.to_a
      end
    end

    #
    alias_method :path, :loadpath
    alias_method :path=, :loadpath=

    # List of requirements.
    attr_accessor :requires do
      PackageList.new([])
    end

    #
    def requires=(list)
      self['requires'] = PackageList.new(list)
    end

    #
    alias_method :requirements,  :requires
    alias_method :requirements=, :requires=

    # List of conflicts.
    attr_accessor :conflicts do
      PackageList.new([])
    end

    #
    def conflicts=(list)
      self['conflicts'] = PackageList.new(list)
    end

    #
    attr_accessor :replaces do
      PackageList.new([])
    end

    #
    def replaces=(list)
      self['replaces'] = PackageList.new(list)
    end

    # Title of package (this defaults to project name capitalized).
    attr_accessor :title do
      name.to_s.capitalize
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

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + codename.to_s + '"'      if codename
      s
    end

    # Convert to hash.
    def to_h
      data = @data.dup
      data['resources'] = data['resources'].to_h
      data
    end

    # TODO: reconcile with above
    def to_h
      @data.inject({}) do |h,(k,v)|
        h[k.to_s] = v; h
      end
    end

    #
    def yaml
      data = {}
      to_h.each do |k,v|
        data[k] = v.respond_to?(:to_data) ? v.to_data : v
      end
      data['version'] = data['version'].to_s
      data['date']    = data['date'].strftime('%Y-%m-%d')
      data.to_yaml
    end

# TODO: Pretty print YAML output
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
=end

    # Read the package file.
    def read!
      if file && file.exist?
        text = File.read(file)
        #text = ERB.new(text).result(Object.new.instance_eval{binding})
        data = YAML.load(text)
        data.each do |k,v|
          __send__("#{k}=", v)
        end
      end
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
#      now!  # update date
      File.open(file, 'w'){ |f| f << yaml }
    end

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
      if @file
        dir = @root + BACKUP_DIRECTORY
        FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
        FileUtils.mkdir(dir) unless dir.directory?
        save!(dir + self.class.filename.first)
      end
    end

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

  end

end
