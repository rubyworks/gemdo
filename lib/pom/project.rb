require 'pom/corext'
require 'pom/metadata'
require 'pom/manifest'
require 'pom/history'
require 'pom/gemspec'

module POM

  # The Project class provides the location of specific directories
  # and files in the project, plus access to the projects metadata, etc.

  class Project

    # Root directory is indicated by the presence of a +meta/+ directory,
    # or +.meta/+ hidden directory.
    ROOT_INDICATORS = [ '{.meta,meta}/' ]

    # File glob for matching README file.
    README = "README{,.*}"

    # Locate the project's root directory. This is determined
    # by ascending up the directory tree from the current position
    # until the ROOT_INDICATOR is matched. Returns +nil+ if not found.
    #
    def self.root(local=Dir.pwd)
      local ||= Dir.pwd
      Dir.chdir(local) do
        dir = nil
        ROOT_INDICATORS.find do |i|
          dir = locate_root_at(i)
        end
        dir ? Pathname.new(File.dirname(dir)) : nil
      end
    end

    #
    def self.locate_root_at(indicator)
      root = nil
      dir  = Dir.pwd
      while !root && dir != '/'
        find = File.join(dir, indicator)
        root = Dir.glob(find, File::FNM_CASEFOLD).first
        #break if root
        dir = File.dirname(dir)
      end
      root ? Pathname.new(root) : nil
    end

    # Instantiate a new Project looking up the root
    # directory form a given local.
    #
    #   Project.lookup(local)
    # 
    def self.lookup(*path_opts)
      path = path_opts.shift unless Hash===options.first
      opts = path_opts.last
      opts[:lookup] =true
      new(path, opts)
    end

    # New project with metadata fully loaded.
    def self.load(*path_opts)
      path = path_opts.shift unless Hash===options.first
      opts = path_opts.last
      opts[:load] =true
      new(path, opts)
    end

    # Instantiate a new project.
    #
    # If a root directory is not given, it will be looked-up starting from
    # the current working directory until a <tt>meta/</tt> directory is found.
    #
    # The +:lookup+ option can be used to induce a lookup from a given location.
    #
    # The +:load+ option can be used to perform a complete metadata load.
    #
    # call-seq:
    #   new()
    #   new(root)
    #   new(root, :load=>true)
    #   new(local, :lookup=>true)
    #
    def initialize(*root_opts)
      root = root_opts.shift unless Hash===root_opts.first
      opts = root_opts.last || {}

      if opts[:lookup] || !root
        root = self.class.root(root)
        raise("cannot locate project root -- #{root}") unless root
      end

      @root = Pathname.new(root)

      metadata.load if opts[:load]

      #if options[:lookup]
      #  @root = locate_root(local) || raise("can't locate project root -- #{local}")
      #end

      # TODO: Support alternate source directory (?)
      @source = root

      #@cache  = root + '.cache'
      #@task   = root + 'task'
      #@script = root + 'script'
      #@log    = root + 'log'
      #@doc    = root + 'doc'

      #@config = root.glob_first('{.,}config') || root + '.config'
      #@plug  = root.glob_first('plug{,in,ins'}) || root + 'plug'
      #@pack  = root.glob_first('{pack,pkg}{,s}') || root + 'pack'

      #@tmp   = Pathname.new(File.join(Dir.tmpdir, 'reap'))
      #@tmp   = cache + 'tmp'
    end

    # Metadata provides all the general information about the project.
    def metadata
      @metadata ||= Metadata.new(root)
    end

    # Project manifest.
    def manifest
      @manifest ||= Manifest.new(root)
    end

    def history
      @history ||= History.new(root)
    end

    # Project manifest file.
    # TODO: Deprecate in favor of using manifest.file ?
    def manifest_file
      @manifest_file ||= root.first('manifest{,.txt}', :casefold)
    end

    # Project's root location. By default this is determined by scanning
    # up from the current working directory in search of the ROOT_INDICATOR.
    attr :root

    # Location of project source code. Currently, this is always
    # the same as the root.
    #
    # TODO: Support alternate source location in the future (?)
    attr :source

    # Get pathname of given log +path+. Or without +path+
    # returns the pathname for the log directory.
    def log(path=nil)
      if path
        log + path
      else
        @log ||= (
          if (site + 'log').directory?
            site + log
          else
            root + 'log'
          end
        )
      end
      #@log ||=(
      #  dir = root.glob_first('{log,doc/log}{,s}') || root + 'doc/log'
      #  dir.mkdir_p unless dir.exist?
      #  dir
      #)
    end

    # Get pathname of given doc +path+. Or without +path+
    # returns the pathname for the doc directory.
    def doc(path=nil)
      if path
        doc + path
      else
        @doc ||= root+'doc'
      end
    end

    # Get pathname of given plugin +path+. Or without +path+
    # returns the pathname for the package directory.
    def pack(path=nil)
      if path
        pack + path
      else
        @pack ||= root.first('{pack,pkg,package}{,s}') || root+'pack'
      end
      #@pkg ||=(
      #  dir = root.glob_first('{pack,pkg}{,s}') || 'pack'
      #  dir.mkdir_p unless dir.exist?
      #  dir
      #)
    end

    # Alias for #pack.
    alias_method :pkg, :pack

    # Get pathname of given cache +path+. Or without +path+
    # returns the pathname for the cache directory.
    def cache(path=nil)
      if path
        cache + path
      else
        @cache ||= root+'.cache'
      end
    end

    # Get pathname of given plugin +path+. Or without +path+
    # returns the pathname for the plugin directory.
    def plug(path=nil)
      if path
        plug + path
      else
        @plug ||= root.first('plug{,in,ins}') || root+'plug'
      end
    end

    # Alias for #plugin.
    alias_method :plugin, :plug

    # Get pathname of given script +path+. Or without +path+
    # returns the pathname for the script directory.
    def script(path=nil)
      if path
        script + path
      else
        @script ||= root+'script'
      end
    end

    # Get pathname of given site +path+. Or without +path+
    # returns the pathname for the site directory.
    def site(path=nil)
      if path
        site + path
      else
        @site ||= root.first('{site,web,website}') || root+'site'
      end
      #@pkg ||=(
      #  dir = root.glob_first('{pack,pkg}{,s}') || 'pack'
      #  dir.mkdir_p unless dir.exist?
      #  dir
      #)
    end

    # Get pathname of given task +path+. Or without +path+
    # returns the pathname for the task directory.
    #
    # TODO: Are task and script different names for the same thing?
    #
    def task(path=nil)
      if path
        task + path
      else
        @task ||= root+'task'
      end
    end

    # Pathname of given config +path+. Or without +path+
    # Returns the path to the config directory (either +.config+
    # or +config+).
    def config(path=nil)
      if path
        config + path #root.glob_first('{.,}config' / path)
      else
        @config ||= root.first('{.,}config') || root+'.config'
      end
    end

    # Get pathname of given temporary +path+. Or without +path+
    # returns the pathname to the temporary directory.
    #--
    # TODO: Use cache + 'tmp' instead ?
    #++
    def tmp(path=nil)
      if path
        tmp + path
      else
        @tmp ||= Pathname.new(Dir.tmpdir) #cache+'tmp'
      end
    end

    # Alias for #tmp.
    alias_method :tmpdir, :tmp

    # About project notice.
    def about(*parts)
      # pre-format data
      released = metadata.released ? "(#{metadata.released.strftime('%Y-%m-%d')})" : nil

      if parts.empty?
        #puts
        #puts "  #{metadata.title} #{metadata.version} (#{metadata.released})"
        #puts
        #puts "  #{metadata.abstract}"
        #puts "  " + metadata.homepage
        #puts
        #puts
        #puts "  Copyright #{metadata.copyright}"
        #puts
        s = []
        s << "#{metadata.title} v#{metadata.version} #{released}"
        s << ""
        s << "#{metadata.description || metadata.summary}"
        s << ""
        s << "  contact    : #{metadata.contact}"
        s << "  homepage   : #{metadata.homepage}"
        s << "  repository : #{metadata.repository}"
        s << "  authors    : #{metadata.authors.join(',')}"
        s << "  package    : #{metadata.package}-#{metadata.version}"
        s << "  requires   : #{metadata.requires.join(',')}"
        s << ""
        s << "#{metadata.copyright}"
        s.join("\n")
      else
        parts.each do |field|
          case field
          #when 'settings'
          #  y settings
          when 'metadata'
            y metadata
          else
            puts metadata.send(field)
          end
        end
      end
    end

    # Project release announcement built on README.
    #
    def announcement(file=nil, options={})
      header = options[:header]

      if file = Dir.glob(file, File::FNM_CASEFOLD).first
        ann = File.read(file)
      else
        release = history.release.to_s

        ann = []
        if file = Dir.glob(README, File::FNM_CASEFOLD).first
          readme  = File.read(file).strip
          readme  = readme.gsub("Please see HISTORY file.", '=' + release)
          ann << readme
        else
          if header
            ann << "#{metadata.title} #{metadata.version} has been released."
            ann << ''
            ann << "* #{metadata.homepage}"
            ann << ''
            ann << "#{metadata.description}"
            ann << ''
          end
          ann << release
        end
        ann = ann.join("\n")
      end
      ann.unfold
    end

  end#class Project

end#module POM

