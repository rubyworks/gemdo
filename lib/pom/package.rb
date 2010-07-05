require 'pom/metafile'
require 'pom/version_file'
#require 'pom/version_helper'
require 'pom/version_number'

module POM

  # Access to PACKAGE (or VERSION) file. The PACKAGE file is a YAML
  # formatted file providing essential information for packaging and
  # library management. A typical example will look like:
  #
  #   ---
  #   name: pom
  #   vers: 1.0.0
  #   date: 2010-06-15
  #   code: POM
  #
  class Package < Metafile

    require 'pom/package/simple_style'
    require 'pom/package/jeweler_style'
    require 'pom/package/pom_style'
    require 'pom/package/jpom_style'

    STYLES = [SimpleStyle, JewelerStyle, POMStyle, JPOMStyle]

    #
    #include VersionHelper

    # Default file name.
    def self.default_filename
      'PACKAGE.yml'
    end

    # Possible project file names.
    def self.filename
      ['PACKAGE', '.package', 'VERSION', '.version']
    end

    #
    def initialize(root, opts={})
      super(root, opts)
    end

    # Project root.
    attr :root

    # Version file.
    attr :file

    # Version number.
    attr_reader :version

    #
    def version=(raw)
      self['version'] = VersionNumber.new(raw)
    end

    # Short name for #version.
    alias_accessor :vers, :version

    # Name of package.
    attr_accessor :name

    # Code name for this package. Only needed if not the default
    # of the +name+ capitalized. For example, +activerecord+ 
    # has a code name of +ActiveRecord+, not Activerecord.
    attr_accessor :code

    #
    alias_accessor :codename, :code

    # Colorful nick name for the particular version, e.g. "Lucid Lynx".
    attr_accessor :nick

    #
    alias_accessor :nickname, :nick

    # Date this version was released.
    attr_reader :date

    #
    def date=(val)
      case val
      when Date, Time, DateTime
        self['date'] = val
      else
        self['date'] = Time.parse(val) if val
      end
    end

    # Internal load paths.
    attr_reader :path do
      ['lib']
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
    alias_accessor :loadpath, :path

    ## Integer-esque revison id, typically from SCM.
    #attr_accessor :revs

    #
    def major
      version.major
    end

    #
    def minor
      version.minor
    end

    #
    def patch
      version.patch
    end

    #
    def build
      version.build
    end

    # Current status (beta, alpha, pre, rc, etc.)
    def status
      if md = /(\w+)/.match(build.to_s)
        md[1].to_sym
      end
    end

    # Set the date to now.
    def now!
      self['date'] = Time.now
    end

    #
    def read!
      if file
        data  = YAML.load(File.new(file.to_s))
        style = STYLES.find{ |s| s.match?(data) }
        extend(style)
        parse(data)
      else
        extend POMStyle
      end

      self.name = fallback_name unless self['name']
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file

      now!  # update date

      out = render

      File.open(file, 'w'){ |f| f << out }
    end

    #
    def to_s
      s = "#{name} #{version}"
      s << " " + date.strftime('%Y-%m-%d') if date
      s << ' "' + nick.to_s + '"'          if nick
      s
    end

    ;; private

    # Failing to find a name for the project, the last hope
    # is to discern it from the lib files.
    def fallback_name
      if file = root.glob('lib/*.rb').first
        file.basename.to_s.chomp('.rb')
      else
        nil
      end
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
