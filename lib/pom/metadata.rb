require 'pom/version'
require 'pom/requires'
require 'pom/resources'

module POM

  # The Metadata class encapsultes all the project information
  # in a canonical form.
  #--
  # TODO: Signing/Certification featuers
  #++
  class Metadata

    # Regular expression for matching valid email addresses.
    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    FILENAME = '.prospec'

    #
    def self.attr_accessor(name)
      module_eval %{
        def #{name}
          @#{name} ||= default('#{name}')
        end
        def #{name}=(value)
          @#{name} = parse('#{name}', value)
        end
      }
    end

    #
    def initialize(root, data={})
      @root = Pathname.new(root).expand_path

      @pom_verison = POM::VERSION

      data.each do |name, value|
        self[name] = value
      end
    end


    # A T T R I B U T E S

    # Name of project/package. Should be all lowercase and one word.
    attr_accessor :name

    # Version number.
    attr_accessor :version

    # Date this version was released.
    attr_accessor :date

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    attr_accessor :codename

    # Namespace for this program. This is only needed if it is not the default
    # of the +name+ capitalized and/or the toplevel namespace is not a module.
    # For example, +activerecord+  uses +ActiveRecord+ for it's namespace,
    # not Activerecord.
    attr_accessor :namespace

    # TODO: Integer-esque build number.
    #attr_accessor :number

    # Revison id from SCM fo current release.
    #attr_accessor :scm_revision_id

    # Internal load paths.
    attr_accessor :loadpath

    # List of files to be included in package.
    attr_accessor :manifest

    # The SCM which the project is currently under
    attr_accessor :scm

    # List of requirements.
    attr_accessor :requires

    # Package this package is known not to work.
    attr_accessor :conflicts

    # Packages this package can replace (should be nearly API compatible).
    attr_accessor :replaces

    # The Ruby engine and their versions required by the project.
    attr_accessor :engines

    # The post-installation message.
    attr_accessor :message

    # Title of package (this defaults to project name capitalized).
    attr_accessor :title

    # A one-line brief description.
    attr_accessor :summary

    # Detailed description.
    attr_accessor :description

    # The suite name.
    attr_accessor :suite

    # Name of the user-account or master-project to which this project belongs. 
    attr_accessor :organization

    # Official contact for this project. This is typically
    # a name and email address.
    attr_accessor :contact

    # The date the project was started.
    attr_accessor :created

    # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
    attr_accessor :copyright

    # License.
    attr_accessor :licenses

    # List of authors.
    attr_accessor :authors

    # List of maintainers.
    attr_accessor :maintainers

    # Table of project URIs encapsulated in a Resources object.
    attr_accessor :resources

    #
    attr_accessor :repositories


    # D E R I V A T I V E S

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
      version.status
    end

    # Contact's email address.
    def email
      if md = RE_EMAIL.match(contact.to_s)
        md[0]
      else
        nil
      end
    end

    # D E F A U L T S

    #
    def default_title
      name.capitalize
    end

    #
    def default_loadpath
      ['lib']
    end

    # Requirements default to an empty PackageList.
    def default_requires
      PackageList.new
    end

    #
    def default_conflicts
      PackageList.new
    end

    #
    def default_replaces
      PackageList.new
    end

    #
    def default_engines
      PackageList.new
    end

    #
    def default_title
      name.to_s.capitalize
    end

    #
    def default_summary
      d = description.to_s.strip
      i = d.index(/(\.|$)/)
      i = 69 if i > 69
      d[0..i]
    end

    #
    def default_copyright
      "Copyright #{Time.now.strftime('%Y')} #{authors.first}"
    end

    #
    def default_licenses
      []
    end

    #
    def default_maintainers
      []
    end

    #
    def default_authors
      []
    end

    #
    def default_maintainers
      authors
    end

    #
    def default_resources
      Resources.new
    end

    #
    def default_repositories
      {} # Repositories.new
    end

    # P A R S E R S

    # Convert version entry into a VersionNumber.
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

    # Returns a list of file paths.
    # TODO: Use Manifest class?
    def parse_manifest(file_or_array)
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

    #
    def parse_licenses(list)
      [list].flatten
    end

    # Set project resources table with a Hash or another Resources object.
    def parse_resources(resources)
      Resources.new(resources)
    end

    # POM Metadatais extensible. If an attribute is assigned that is not
    # already defined by an attribute reader then an entry will be created
    # for it.
    def method_missing(sym, *args)
      meth = sym.to_s
      name = meth.chomp('=')
      case meth
      when /=$/
        self[name] = args.first
      else
        if block_given? or args.size > 0
          super(sym, *args)
        else
          self[name]
        end
      end
    end

    # Override standard #respond_to? method to take
    # method_missing lookup into account.
    def respond_to?(name)
      return true if super(name)
      return true if key?(name)
      return false
    end

    # Get or set an attribute if a +value+ is given.
    def value(name, value=nil)
      self[name] = value if value
      self[name]
    end

    # H A S H - L I K E  A C C E S S
 
    #
    def [](name)
      instance_variable_get("@#{name}")
    end

    #
    def []=(name, value)
      instance_variable_set("@#{name}", parse(name, value))
    end

    #
    def key?(name)
      instance_variable_defined?("@#{name}")
    end

    # Returns an Array of metadata attribute names.
    def attributes
      instance_variables.map{ |iv| iv.sub('@','') }
    end

    #
    def to_h
      h = {}
      instance_variables.each do |iv|
        next if iv == '@root'
        name = iv.sub('@','')
        h[name] = self[name]
      end
      h['version']   = h['version'].to_s
      h['requires']  = h['requires'].to_data  if h['requires']
      h['conflicts'] = h['conflicts'].to_data if h['conflicts']
      h['replaces']  = h['replaces'].to_data  if h['replaces']
      h['resources'] = h['resources'].to_h    if h['resources']
      h
    end

    # F I L E  H A N D L I N G

    #
    def canonical_file
      root + FILENAME
    end

    #
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
        f << to_h.to_yaml
      end
    end

    # Backup the cannonical file.
    def backup!(file=nil)
      file = file || FILENAME
      dir = root + BACKUP_DIRECTORY
      FileUtils.mkdir(dir.dirname) unless dir.dirname.directory?
      FileUtils.mkdir(dir) unless dir.directory?
      save!(dir + FILENAME)
    end


    private

    #
    def default(name)
      if respond_to?("default_#{name}")
        __send__("default_#{name}")
      else
        nil
      end
    end

    #
    def parse(name, value)
      if respond_to?("parse_#{name}")
        value = __send__("parse_#{name}", value)
      end
      value
    end

    # TODO: Pretty print YAML output ?
=begin
    # Set PACKAGE filepath.
    def file=(file)
      @file = file
    end

    # The date the project was started.
    attr_accessor :created


    # Set project resources table with a Hash or another Resources object.
    def resources=(resources)
      self['resources'] = Resources.new(resources)
    end

    # Profile is extensible. If a setting is assigned
    # that is not already defined an attribute accessor
    # will be created for it.

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
=end

  end

end
