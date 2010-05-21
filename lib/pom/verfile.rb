require 'pom/yamlstore'

module POM

  #--
  # Is this 'package' information. Might we call it that?
  #++
  class Verfile < YAMLStore

    #
    def self.filename
      ['VERSION', '.version']  # '.package' ?
    end

    # Project's <i>package name</i>. The entry is required
    # and must not contain spaces or puncuation.
    attr_accessor :name

    #
    attr_accessor :major

    #
    attr_accessor :minor

    #
    attr_accessor :patch

    # Current status (beta, alpha, rc, etc.)
    attr_accessor :state

    #
    attr_accessor :build

    # Date this version was released.
    attr_accessor :date

    # Code name of the release (eg. Woody)
    # TODO: better name for this?
    attr_accessor :code

    # Platforms this project/package supports (+nil+ for universal).
    attr_accessor :arch

    # Load path(s) (used by Ruby's own site loading and RubyGems).
    # The default is 'lib/', which is usually correct.
    attr_accessor :paths, ['lib']

    # Current version of the project. Will be a dot separated
    # string, e.g. "1.0.0".
    def version
      to_a.join('.')
    end

    #
    def date=(val)
      case val
      when Date, Time, DateTime
        @date = val
      else
        @date = Date.parse(val) if val
      end
    end

    #
    def version=(string)
      @major, @minor, @patch, @state, @build = *string.split('.')
      unless /[A-Za-z]/ =~ state 
        @build = state
        @state = nil
      end
    end

    # Current version of the project. Will be a dot separated
    # string, e.g. "1.0.0".
    def to_s
      to_a.join('.')
    end

    def to_a
      [major, minor, patch, state, build].compact
    end

    #
    def loadpath
      paths
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.filename.first
      file = @root + file if String === file
      File.open(file, 'w') do |f|
        f.puts "name : #{name}"
        f.puts "major: #{major}"
        f.puts "minor: #{minor}" if minor
        f.puts "patch: #{patch}" if patch
        f.puts "state: #{state}" if state
        f.puts "build: #{build}" if build
        f.puts "date : #{date.strftime('%Y-%m-%d')}" if date
        f.puts "paths: #{paths.inspect}" if paths && paths != ["lib"]
        f.puts "arch : #{arch.inspect}"  if arch
      end
    end

    # TODO: Parse irregular VERSION files.
    def parse_version_stamp
      if file = root.glob('{VERSION,Version,version}{,.txt}').first
        vers = YAML.load(File.new(file))
        case vers
        when Hash
          vers = vers.inject({}){ |h,(k,v)| h[k.to_s.downcase.to_sym] = v; h }
          @data['version'] = "#{vers[:major]}.#{vers[:minor]}.#{vers[:patch]}"
        when Array
          @data['version'] = vers.join('.')
        else #String
          @data['version'] = vers
        end
      end
    end

  end

end
