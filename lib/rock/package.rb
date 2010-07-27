#require 'pom/metafile'
#require 'pom/version_file'
#require 'pom/version_helper'
require 'pom/version_number'
require 'pom/require'

module POM

  # The Package class encapsulates essential information for packaging and
  # library management. This information will usually derive from a YAML
  # document. A typical example will look like:
  #
  #   ---
  #   name: pom
  #   vers: 1.0.0
  #   date: 2010-06-15
  #   module: POM
  #
  class Package

    #
    #def self.find(root)
    #  root = Pathname.new(root)
    #  pattern = '{,.}{' + filename.join(',') + '}{.yml,.yaml,}'
    #  root.glob(pattern, :casefold).first
    #end

    #require 'pom/package/simple_style'
    #require 'pom/package/jeweler_style'
    #require 'pom/package/pom_style'
    #require 'pom/package/jpom_style'

    #STYLES = [SimpleStyle, JewelerStyle, POMStyle, JPOMStyle]

    #
    #include VersionHelper

    # Default file name.
    #def self.default_filename
    #  '.ruby/package'
    #end

    # Possible project file names.
    #def self.filename
    #  ['.ruby/package', 'Rubyfile', 'PACKAGE']
    #end

    #
    def initialize(data={})
      #@root = Pathname.new(root)
      initialize_defaults
      data.each{ |k,v| __send__("#{k}=", v) }
      #read!
    end

    #
    def initialize_defaults
      @file = self.class.find(root)
      @path = ['lib']
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

    # Version number.
    def version
      @version
    end

    #
    def version=(raw)
      @version = VersionNumber.new(raw)
    end

    # Short name for #version.
    alias_method :vers,  :version
    alias_method :vers=, :version=

    # Name of package.
    def name
      @name
    end

    # Set name of package.
    def name=(name)
      @name = name
    end

    # Date this version was released.
    def date
      @date
    end

    # Set release date.
    def date=(val)
      case val
      when Date #, Time, DateTime
        @date = val
      else
        @date = Date.parse(val) if val
      end
    end

    # Integer-esque build number.
    #attr_accessor :no

    # Integer-esque revison id from SCM.
    #attr_accessor :id

    #
    alias_method :release,  :date
    alias_method :release=, :date=

    #
    alias_method :release_date, :date

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    attr_accessor :codename

    #
    alias_method :code,  :codename
    alias_method :code=, :codename=

    #alias_method :moniker,  :nick
    #alias_method :monicker, :nick # because clowns are funny

    # Namespace for this package. Only needed if not the default
    # of the +name+ capitalized. For example, +activerecord+ 
    # uses +ActiveRecord+ for it's namespace, not Activerecord.
    attr_accessor :module

    # Internal load paths.
    def path
      @path
    end

    #
    def path=(path)
      case path
      when NilClass
        self['path'] = ['lib']
      when String
        self['path'] = path.split(/[,:;\ ]/)
      else
        self['path'] = path.to_a
      end
    end

    #
    alias_method :loadpath,  :path
    alias_method :loadpath=, :path=

=begin
    # List of requirements.
    attr_reader :requires

    #
    def requires=(requirements)
      @requires = Requirements.new(requirements)
    end

    #
    alias_method :requirements,  :requires
    alias_method :requirements=, :requires=
=end

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
      @date = Time.now
    end

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + nick.to_s + '"'          if nick
      s
    end

    #
    def yaml
      s = []
      s << "name: #{name}"
      s << "vers: #{version}"
      s << "date: #{date.strftime('%Y-%m-%d')}"
      s << ""
      s << "require:"
      requires.each do
        s << "- " + req.yaml.tabto(2)
      end
      s.join("\n")
    end

=begin
    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      now!  # update date
      File.open(file, 'w'){ |f| f << yaml }
    end

    #
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

    #
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      File.open(file, 'w') do |f|
        f << yaml #to_h.to_yaml
      end
    end

    #
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
    #     RELEASE  = "2010-10-01"
    #     CODENAME = "Fussy Foo"
    #   end
    #
    def save_as_ruby(file)
      if File.exist?(file)
        text = File.read(file)
        save_as_ruby_sub!(text, :version, 'VERSION')
        save_as_ruby_sub!(text, :release, 'RELEASE', 'DATE')
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

