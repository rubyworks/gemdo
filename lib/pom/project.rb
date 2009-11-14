require 'pom/corext'
require 'pom/root'
require 'pom/metadata'
require 'pom/manifest'
require 'pom/history'
require 'pom/gemspec'

module POM

  # The Project class provides the location of specific directories
  # and files in the project, plus access to the projects metadata, etc.

  class Project

    # File glob for matching README file.
    README = "README{,.*}"

    # Locate the project's root directory. See POM::root.
    def self.root(local=Dir.pwd)
      POM.root(local)
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
      opts[:load] = true
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

    # Access to project history.

    def history
      @history ||= History.new(root)
    end

    # Project manifest file name.
    #
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

    # The <tt>log/</tt> directory stores log output created by 
    # build tools.
    #
    #--
    # Alternately this can be located in the #site
    # directory if you wish to publish your logs.
    #++
    #
    # Get pathname of given log +path+. Or without +path+
    # returns the pathname for the log directory.

    def log(path=nil)
      if path
        log + path
      else
        @log ||= (
          #if (site + 'log').directory?
          #  site + log
          #else
            root + 'log'
          #end
        )
      end
      #@log ||=(
      #  dir = root.glob_first('{log,doc/log}{,s}') || root + 'doc/log'
      #  dir.mkdir_p unless dir.exist?
      #  dir
      #)
    end

    # The doc directory is the place to keep documentation. The directory
    # is intended to be distributed with a package, but this is not often
    # done these days since RubyGems generates RDocs on demand, and
    # documentation is often found online.
    #
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
    #
    # This is aliaed as #pkg.

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

    # The <tt>.cache/</tt> directory is used by build tools to
    # store temporary files. For instance, the +pom+ command uses
    # it to store backups of metadata entries when overwriting
    # old entries. <tt>.cache/</tt> should be in your SCM's
    # ignore list.
    #
    # Get pathname of given cache +path+. Or without +path+
    # returns the pathname for the cache directory.

    def cache(path=nil)
      if path
        cache + path
      else
        @cache ||= root+'.cache'
      end
    end

    # The <tt>plug/</tt> directory serves the same purpose as 
    # the <tt>lib/</tt> directory. It simply provides a place
    # to put plugins separate from the main <tt>lib/</tt> files.
    #
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

    # The <tt>script/</tt> directory is like the <tt>task/</tt> 
    # directory but usually holds executables that are made
    # available to the end-installers.
    #
    # Get pathname of given script +path+. Or without +path+
    # returns the pathname for the script directory.

    def script(path=nil)
      if path
        script + path
      else
        @script ||= root+'script'
      end
    end

    # The <tt>site/</tt> directory (also web/ or website/) is
    # where a project's website is stored.
    #
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

    # The <tt>task/</tt> directory is where task scripts are 
    # stored used by build tools, such as Rake and Syckle.
    #
    # Get pathname of given task +path+. Or without +path+
    # returns the pathname for the task directory.

    def task(path=nil)
      if path
        task + path
      else
        @task ||= root.first('{task,tasks}') || root+'task'
      end
    end

    # The <tt>.config/</tt> or <tt>config</tt> directory is a place
    # for build tools to place their configration files.
    #
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

    # Not strickly a project directory. THis provides a temporary
    # system location outside the project directory.
    # 
    # Get pathname of given temporary +path+. Or without +path+
    # returns the pathname to the temporary directory.
    #
    # TODO: Add name to end of path ?

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
    # TODO: Don't use README, or make it an option.
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

