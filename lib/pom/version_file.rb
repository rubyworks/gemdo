require 'pom/version_helper'

module POM

  # Access to VERSION file. This class supports plain-text
  # and YAML formatted files.
  class VersionFile

    #
    include VersionHelper

    #
    FILE_PATTERN = 'VERSION{,.txt,.yml,.yaml}'

    #
    def self.file_pattern
      FILE_PATTERN
    end

    #
    def self.find(root)
      root.glob(file_pattern, File::FNM_CASEFOLD).first
    end

    #
    def initialize(root, opts={})
      @root = Pathname.new(root)
      @file = opts[:file] || self.class.find(root)
      read_version_file
    end

    # Project root.
    attr :root

    # Version file.
    attr :file

    # Version number.
    attr_reader :version

    #
    attr_accessor :name

    # Date this version was released.
    attr_reader :date

    # Code name for this release, e.g. "Hardy Haron".
    attr_accessor :codename

    # Integer(esque) build number.
    attr_accessor :buildno

    #
    def version=(raw)
      @version = VersionNumber.new(raw)
    end

    #
    def date=(val)
      case val
      when Date, Time, DateTime
        @date = val
      else
        @date = Time.parse(val) if val
      end
    end

    # Current status (beta, alpha, pre, rc, etc.)
    def status
      if md = /(\w+)/.match(version.build.to_s)
        md[1].to_sym
      end
    end

    # Current version of the project. Will be a dot separated
    # string, e.g. "1.0.0".
    def to_s
      @version.to_s
    end

    #
    def to_a
      @version.to_a
    end

    #
    def read_version_file
      if file 
        text = File.read(file).strip
        if yaml?(file, text)
          @type = :yaml
          release = parse_release_hash(YAML.load(text))
        else
          @type = :text
          release = parse_release_stamp(text)
        end
        self.version  = release[:version]
        self.date     = release[:date]
        self.codename = release[:codename]
      end
    end

    # TODO: handle jeweler and non-jeweler yaml?
    def save_version_file
      now!
      case type
      when :text
        File.write(file, 'w'){ |f| f << version.to_s }
      when :yaml
        File.write(file, 'w'){ |f| f << version.to_h.to_yaml }
      else
        File.write(file, 'w'){ |f| f << version.to_h.to_yaml }
      end
    end

    ## This method is not using #to_yaml in order to ensure
    ## the file is saved neatly. This may require tweaking.
    #def save_version_file_in_yaml
    #  File.open(file, 'w') do |f|
    #    #f.puts "name : #{name}"
    #    f.puts "major: #{major}"
    #    f.puts "minor: #{minor}" if minor
    #    f.puts "patch: #{patch}" if patch
    #    f.puts "build: #{build}" if build
    #    f.puts "date : #{date.strftime('%Y-%m-%d')}"
    #  end
    #end

  private

    #
    def yaml?(file, text)
      return true if file.extname == '.yml'
      return true if file.extname == '.yaml'
      return true if text[0,3] == '---'
      return true if text.index('major:')
      false
    end

  end

end

