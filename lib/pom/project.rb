require 'pom/core_ext'
require 'pom/root'
#require 'pom/metadata'
require 'pom/manifest'
require 'pom/history'
require 'pom/news'
require 'pom/spec'
require 'pom/profile'

require 'pom/project/paths'
require 'pom/project/files'
require 'pom/project/utils'

module POM

  # The Project class provides the location of specific directories
  # and files in the project, plus access to the projects metadata, etc.
  class Project

    include Paths
    include Files
    include Utils

    # Project's root location. By default this is determined by scanning
    # up from the current working directory in search of the ROOT_INDICATOR.
    attr :root

    #
    def metadata
      @metadata ||= profile #Rubyspec.new(root)
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
      released = metadata.date ? "(#{metadata.date.strftime('%Y-%m-%d')})" : nil
      if parts.empty?
        s = []
        s << "#{metadata.title} v#{metadata.version} #{released} (#{metadata.name}-#{metadata.version})"
        s << ""
        s << "#{metadata.description || metadata.summary}"
        s << ""
        s << "* home: #{metadata.resources.homepage}"   if metadata.resources.home
        s << "* work: #{metadata.resources.work}"       if metadata.resources.work
        s << "* mail: #{metadata.resources.mail}"       if metadata.resources.mail
        s << "* chat: #{metadata.resources.forum}"      if metadata.resources.chat
        s << "* repo: #{metadata.resources.repository}" if metadata.resources.repo
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

    # Instantiate a new Project object.
    #
    # If a root directory is not given, it will be looked-up starting from
    # the current working directory until a <tt>.ruby/</tt> file is found.
    #
    # The +:lookup+ option can be used to induce a lookup from a given location.
    #
    # call-seq:
    #   new()
    #   new(root)
    #   new(local, :lookup=>true)
    #
    def initialize(*args)
      root = args.shift unless Hash===arge.first
      opts = args.last || {}

      if opts[:lookup] || !root
        find(root || Dir.pwd)
      else
        raise("cannot locate project root -- #{root}") unless root
      end

      @root = Pathname.new(root)
      @opts = opts

      #metadata.load #if opts[:load]

      #if options[:lookup]
      #  @root = locate_root(local) || raise("can't locate project root -- #{local}")
      #end
    end

    # Find project root.
    def find(dir=Dir.pwd)
      @root = self.class.root(dir)
    end

    # Instantiate a new Project looking up the root directory form a given local.
    #
    #   Project.lookup(local)
    # 
    def self.lookup(*path_opts)
      path = path_opts.shift unless Hash === path_opts.first
      opts = path_opts.last || {}
      opts[:lookup] =true
      new(path, opts)
    end

    ## New project with metadata fully loaded.
    ##def self.load(*path_opts)
    ##  path = path_opts.shift unless Hash === path_opts.first
    ##  opts = path_opts.last || {}
    ##  opts[:load] = true
    ##  new(path, opts)
    ##end

    # Root directory is indicated by the presence of either a
    # .ruby file or as a fallback a lib/ directory.
    ROOT_INDICATORS = ['.rubyspec', '.ruby', '.git', '.hg', '_darcs', 'lib/']

    # Locate the project's root directory. This is determined
    # by ascending up the directory tree from the current position
    # until a root indicator is matched. Returns +nil+ if not
    # found.

    def self.root(dir=Dir.pwd)
      dir  = File.expand_path(dir)
      home = File.expand_path('~')  # Better way?
      ROOT_INDICATORS.find do |marker|
        while dir != home && dir != '/'
          if File.exist?(File.join(dir, marker))
            break dir
          else
            dir = File.dirname(dir)
          end
        end
      end
      dir ? Pathname.new(dir) : nil
    end

  end#class Project

end#module POM
