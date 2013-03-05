require 'indexer'
require 'readme'
require 'history'
require 'mast'

require 'facets/string/unfold'

require 'pom/core_ext'
require 'pom/error'

require 'pom/project/news'
require 'pom/project/manifest'  # TODO: Use mast instead
require 'pom/project/paths'


module POM

  # The Project class provides the location of specific directories
  # and files in the project, plus access to the projects metadata, etc.
  class Project

    # Instantiate a new Project object.
    #
    # If a root directory is not given, it will be looked-up starting from
    # the current working directory until a root indicator is found.
    #
    # The +:lookup+ option can be used to induce a lookup from a given location.
    #
    # call-seq:
    #   new()
    #   new(root)
    #   new(local, :lookup=>true)
    #
    def initialize(root=nil)
      @root = Pathname.new(root || Dir.pwd).expand_path

      unless @root.directory?
        raise(ProjectNotFound,"#{@root} is not a directory")
      end
      
      #metadata.load #if opts[:load]
    end

    # Find project root.
    def find(dir=Dir.pwd)
      @root = self.class.root(dir)
    end

    # Project's root location. By default this is determined by scanning
    # up from the current working directory in search of the ROOT_INDICATOR.
    attr :root

    # Metadata from .ruby file.
    def metadata
      @metadata ||= Indexer::Metadata.find
    end

    # Project name.
    def name
      metadata.name
    end

    # Version number string representation, e.g. "1.0.0".
    def version
      metadata.version
    end

    #
    def codename
      metadata.codename
    end

    #
    def loadpath
      metadata.loadpath
    end

    # Requirements Configuration.
    def requires
      metadata.requires
    end

    #
    alias_method :requirements, :requires

    # For the most common project metadata, explict methods have been
    # defined. For the rest #method_missing is used.
    def method_missing(name, *args, &block)
      if metadata.respond_to?(name)
        metadata.send(name, *args, &block)
      else
        super(name, *args, &block)
      end
    end

    # Package name is generally in the form of +name-version+,
    # or +name-version-platform+ if +platform+ is specified.
    def package_name(options={})
      if platform = options[:platform]
        "#{name}-#{version}-#{platform}"
      else
        "#{name}-#{version}"
      end
    end

    # DEPRECATE
    alias_method :stage_name, :package_name

    # About project notice.
    def about(*parts)
      # pre-format data
      #released = metadata.date ? "(#{metadata.date.strftime('%Y-%m-%d')})" : nil
      if parts.empty?
        s = []
        s << "#{metadata.title} v#{metadata.version} (#{metadata.name}-#{metadata.version})"
        s << ""
        s << "#{metadata.description || metadata.summary}"
        s << ""
        s << "* home: #{metadata.resources.home}"      if metadata.resources.home
        s << "* work: #{metadata.resources.work}"      if metadata.resources.work
        s << "* mail: #{metadata.resources.mail}"      if metadata.resources.mail
        s << "* chat: #{metadata.resources.forum}"     if metadata.resources.chat
        #s << "* repo: #{metadata.resources.repository}"if metadata.resources.repo
        s << ""
        s << "#{metadata.copyright}"
        s.join("\n").gsub("\n\n\n", "\n\n")
      else
        parts.each do |field|
          case field.to_sym
          #when :settings
          #  puts settings.to_yaml
          when :metadata
            puts metadata.to_yaml
          else
            puts metadata.__send__(field)
          end
        end
      end
    end

    # Does a file exist in the project?
    # Returns the first match.
    def file?(glob)
      Pathname.glob(root + glob).first
    end

    # Determines if a directory exists within the project.
    #
    # @param [String] path
    #   The path of the directory, relative to the project.
    #
    # @return [Pathname]
    #   The path if it exists, otherwise `nil`.
    def directory?(path)
      dir = root.join(path)
      dir.directory? ? dir : nil
    end

    # Lookup project paths using a fluent notation.
    #
    # @example
    #   project.path.doc  #=> 'foo/doc'
    #
    def path
      @path ||= Paths.new(self)
    end

    # Returns list of executable files in bin/.
    def executables
      Pathname.glob(path.bin + '*').select{ |b| b.executable? }.map{ |b| b.basename }
    end

    # List of extension configuration scripts.
    # These are used to compile the extensions.
    def extensions
      Pathname.glob(path.ext + '**/extconf.rb')
    end

    # Returns +true+ if the project have native extensions.
    def compiles?
      !extensions.empty?
    end


    # M A N I F E S T

    # Project manifest.
    #
    # For manifest file use `manifest.file`.
    def manifest
      @manifest ||= Manifest.new(root)
    end


    # R U B Y G E M S

    #
    def gemspec
      @gemspec ||= Gem::Specification.load(gemspec_file)
    end

    #
    def gemspec_file
      @gemspec_file ||= (
        require_rubygems
        Pathname.glob(root + "{*,}.gemspec").first
      )
    end

    # Require RubyGems library.
    def require_rubygems
      begin
        require 'rubygems' #/specification'
        #::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed."
      end
    end
    private :require_rubygems


    # R E A D M E

    # Access to the general +README+ file
    def readme
      @readme ||= Readme.new(root)
    end

    # TODO: Isn't readme.file good enough?
    def readme_path
      Pathname.glob(root + Readme::FILE_PATTERN, File::FNM_CASEFOLD).first
    end


    # H I S T O R Y

    # Access to project history.
    #
    # For history file use `history.file`.
    def history
      @history ||= History.at(root)
    end

    # Access latest release notes.
    def news
      @news ||= News.new(root, :history=>history)
    end


    # M I S C E L L A N E O U S

    # Project release announcement built on README.
    def announcement(*parts)
      ann = []
      parts.each do |part|
        case part.to_sym
        when :message
          ann << "#{metadata.title} #{self.version} has been released."
        when :description
          ann << "#{metadata.description}"
        when :resources
          list = ''
          metadata.resources.each do |r|
            name = r.label || r.type.to_s.capitalize
            if name
              list << "* #{name}: #{r.uri}\n"
            else
              list << "* #{r.uri}\n"
            end
          end
          ann << list
        when :release
          ann << "= #{title} #{history.release}"
        when :version
          ann << "= #{history.release.header}"
        when :notes
          ann << "#{history.release.notes}"
        when :changes
          ann << "#{history.release.changes}"
        #when :line
        #  ann << ("-" * 4) + "\n"
        when :readme
          release = history.release.to_s
          if readme_file
            readme  = File.read(readme_file).strip
            readme  = readme.gsub("Please see HISTORY file.", '= ' + release)
            ann << readme
          end
        when String
          ann << part
        when File
          ann << part.read
          part.close
        end
      end
      ann.join("\n\n").unfold
    end


    # Instantiate a new Project looking up the root directory form a given
    # local directory.
    def self.find(dir=Dir.pwd)
      if root_dir = root(dir)
        new(root_dir)
      else
        raise(ProjectNotFound, "Could not find #{ROOT_INDICATORS.join(' or ')}.")
      end
    end

    ## New project with metadata fully loaded.
    ##def self.load(*path_opts)
    ##  path = path_opts.shift unless Hash === path_opts.first
    ##  opts = path_opts.last || {}
    ##  opts[:load] = true
    ##  new(path, opts)
    ##end

    # Root directory is indicated by the presence of either a `.ruby` file,
    # scm directory like `.git`, or, as a fallback, a `lib/` directory.
    ROOT_INDICATORS = ['.ruby', '.git', '.hg', '_darcs', '.gemspec', '*.gemspec', 'Gemfile', 'lib/']

    # Locate the project's root directory. This is determined
    # by ascending up the directory tree from the current position
    # until a root indicator is matched. It tries one indicator
    # at a time to reduce the chance of a false positive, and will
    # not search past the current home directory.
    #
    # Returns +nil+ if not found.

    def self.root(dir=Dir.pwd)
      home = Pathname.new('~').expand_path
      ROOT_INDICATORS.each do |root_indicator|
        Pathname.new(dir).ascend do |root|
          break if root == home
          return root if Dir.glob(root.join(root_indicator).to_s).first
        end
      end
      return nil
    end

  end#class Project

end#module POM
