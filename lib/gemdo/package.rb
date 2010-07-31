#require 'gemdo/metafile'
#require 'gemdo/version_file'
#require 'gemdo/version_helper'
require 'fileutils'
require 'gemdo/version'
require 'gemdo/requires'

module Gemdo

  # The Package class encapsulates essential information for packaging and
  # library management. This information will usually derive from a YAML
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
  class Package

    BACKUP_DIRECTORY = '.cache/gemdo'

    #
    def self.find(root)
      root = Pathname.new(root)
      pattern = '{,.}{' + filename.join(',') + '}{.yml,.yaml,}'
      root.glob(pattern, :casefold).first
    end

    #require 'pom/package/simple_style'
    #require 'pom/package/jeweler_style'
    #require 'pom/package/pom_style'
    #require 'pom/package/jpom_style'

    #STYLES = [SimpleStyle, JewelerStyle, POMStyle, JPOMStyle]

    #
    #include VersionHelper

    # Default file name.
    def self.default_filename
      'PACKAGE'
    end

    # Possible project file names.
    def self.filename
      ['[Pp]ackage', 'PACAKGE']
    end

    #
    def initialize(root, data={})
      @root  = Pathname.new(root)
      @table = {}
      initialize_defaults
      data.each{ |k,v| __send__("#{k}=", v) }
      read!
    end

    #
    def initialize_defaults
      @file = self.class.find(root) || root + self.class.default_filename
      @table[:loadpath]  = ['lib']
      @table[:requires]  = []
      @table[:conflicts] = []
      @table[:replaces]  = []
    end

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

    #
    def [](key)
      @table[key.to_sym]
    end

    #
    def []=(key, value)
      @table[key.to_sym] = value
    end

    # Name of package.
    def name
      self[:name]
    end

    # Set name of package.
    def name=(name)
      self[:name] = name
    end

    # Version number.
    def version
      self[:version]
    end

    #
    def version=(raw)
      self[:version] = VersionNumber.new(raw)
    end

    # Short name for #version.
    alias_method :vers,  :version
    alias_method :vers=, :version=

    # Date this version was released.
    def date
      self[:date]
    end

    # Set release date.
    def date=(val)
      case val
      when Date #, Time, DateTime
        self[:date] = val
      else
        self[:date] = Date.parse(val) if val
      end
    end

    #
    alias_method :released,  :date
    alias_method :released=, :date=

    #
    alias_method :release_date, :date

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    def codename
      self[:codename]
    end

    #
    def codename=(codename)
      self[:codename]=codename
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
      self[:namespace]
    end

    # Set namespace.
    def namespace=(ns)
      case ns
      when /^class/, /^module/
        self[:namespace] = ns.strip
      else
        self[:namespace] = "module #{ns.strip}"
      end
    end

    # TODO: Integer-esque build number.
    #attr_accessor :no

    # TODO: Integer-esque revison id from SCM.
    #attr_accessor :id

    # Internal load paths.
    def loadpath
      self[:loadpath]
    end

    #
    def loadpath=(path)
      case path
      when NilClass
        self[:loadpath] = ['lib']
      when String
        self[:loadpath] = path.split(/[,:;\ ]/)
      else
        self[:loadpath] = path.to_a
      end
    end

    #
    alias_method :path, :loadpath
    alias_method :path=, :loadpath=

    # List of requirements.
    def requires ; self[:requires] ; end

    #
    def requires=(list)
      self[:requires] = Requires.new(list)
    end

    #
    alias_method :requirements,  :requires
    alias_method :requirements=, :requires=

    #
    def conflicts ; self[:conflicts] ; end

    #
    def conflicts=(list)
      self[:conflicts] = Conflicts.new(list)
    end

    #
    def replaces ; self[:replaces] ; end

    #
    def replaces=(list)
      self[:replaces] = Replaces.new(list)
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

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + codename.to_s + '"'      if codename
      s
    end

    #
    def to_h
      @table
    end

    #
    def yaml
      s = []
      s << "name: #{name}"
      s << "vers: #{version}"
      s << "date: #{date.strftime('%Y-%m-%d')}"
      s << ""
      if !requires.empty?
        s << "requires:"
        requires.each do |req|
          s << "- " + req.yaml.tabto(2)
        end
      end
      s.join("\n")
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
      now!  # update date
      File.open(file, 'w'){ |f| f << yaml }
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

  end

end


=begin
   #     # If there are .ruby entries, start by picking up those.
   #   if RubyDir.find(root)
   #     self.name = rubydir.name
   #     self.vers = rubydir.version
   #     self.date = rubydir.date
   #     self.code = rubydir.codename #nickname
   #     self.nick = rubydir.namespace
   #     self.path = rubydir.loadpath
   #   end
=end

=begin
    # TODO: Should rubydir version be a VERSION object?
    def verify_rubydir(rubydir)
      s = []
      s << [rubydir.name, name]           unless rubydir.name      == name
      s << [rubydir.version, version]     unless rubydir.version   == version
      s << [rubydir.loadpath, loadpath]   unless rubydir.loadpath  == loadpath
      s << [rubydir.date, date]           unless rubydir.date      == date
      s << [rubydir.namespace, namespace] unless rubydir.namespace == namespace
      s << [rubydir.moniker, moniker]     unless rubydir.moniker   == moniker
      s.each do |rd, pk|
        warn ".ruby is out of sync with PACKAGE (#{rd} != #{pk})"
      end
      s.empty?
    end
=end

=begin
    # Failing to find a name for the project, the last hope
    # is to discern it from the lib files.
    #
    # TODO: Is this really a good idea?
    def fallback_name
      if file = root.glob('lib/*.rb').first
        file.basename.to_s.chomp('.rb')
      else
        nil
      end
    end
=end

    #
    #def read!
    #  if file
    #    data  = YAML.load(File.new(file.to_s))
    #    style = STYLES.find{ |s| s.match?(data) }
    #    extend(style)
    #    parse(data)
    #  else
    #    extend POMStyle
    #  end
    #
    #  self.name = fallback_name unless self['name']
    #end

