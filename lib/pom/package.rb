require 'pom/metafile'
require 'pom/version_helper'
require 'pom/version_number'

module POM

  # Access to PACKAGE file. The PACKAGE file is a YAML
  # formatted file providing essential information for
  # the packaging and library management. A typical
  # example will look like:
  #
  #   ---
  #   name: pom
  #   vers: 1.0.0
  #   date: 2010-06-15
  #
  #   module: POM
  #
  class Package < Metafile

    #
    include VersionHelper

    #
    def self.default_filename
      'PACKAGE.yml'
    end

    #
    def initialize(root, opts={})
      @segmented = false
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

    # Name of package.
    attr_accessor :name

    # Code name for this package. Only needed if not the default
    # of the +name+ capitalized. For example, +activerecord+ 
    # has a code name of +ActiveRecord+, not Activerecord.
    attr_accessor :code

    #
    alias_accessor :codename, :code

    # Colorful release name, e.g. "Hardy Haron".
    # TODO: Better name?
    attr_accessor :bill

    #
    alias_accessor :billname, :bill

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

    # Current version of the project. Will be a dot separated
    # string, e.g. "1.0.0".
    #def to_s
    #  @version.to_s
    #end

    #
    #def to_a
    #  @version.to_a
    #end

    #
    def read!
      if file 
        #text = File.read(file).strip
        data = YAML.load(File.new(file))
        data = data.inject({}){|h,(k,v)| h[k.to_s] = v; h}
        if data['major']
          @segmented = true
          self.version = data.values_at('major','minor','patch','build').compact
        else
          @segmented = false
          self.version = data['vers'] || data['version']
        end
        self.name = data['name']
        self.date = data['date']
        self.code = data['code'] || data['codename']
        self.path = data['path'] || data['loadpath'] || ['lib']
      end
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file

      now!

      File.open(file, 'w') do |f|
        f.puts "name: #{name}"
        f.puts "date: #{date.strftime('%Y-%m-%d')}"
        if @segmented
          f.puts
          f.puts "major: #{major}"
          f.puts "minor: #{minor}" if minor
          f.puts "patch: #{patch}" if patch
          f.puts "build: #{build}" if build
          f.puts
        else
          f.puts "vers: #{version}"
        end
        f.puts "code: #{code}" if code
        f.puts "bill: #{bill}" if bill
        f.puts "path: #{path.inspect}" if path
      end
    end

  end

end

