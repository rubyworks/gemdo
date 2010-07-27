require 'rock/core_ext'
require 'rock/root'
require 'rock/metadata'
require 'rock/manifest'
require 'rock/history'
require 'rock/news'
require 'rock/package'
require 'rock/profile'

module Rock

  # The Project class provides the location of specific directories
  # and files in the project, plus access to the projects metadata, etc.
  class Project

    # File glob for matching README file.
    README = "README{,.*}"

    # Locate the project's root directory. See Rock::root.
    def self.root(local=Dir.pwd)
      Rock.root(local)
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
    # the current working directory until a <tt>.ruby/</tt> file is found.
    #
    # The +:lookup+ option can be used to induce a lookup from a given location.
    #
    # call-seq:
    #   new()
    #   new(root)
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
      @opts = opts

      #metadata.load #if opts[:load]

      #if options[:lookup]
      #  @root = locate_root(local) || raise("can't locate project root -- #{local}")
      #end

      @source = root
    end

    # Project's root location. By default this is determined by scanning
    # up from the current working directory in search of the ROOT_INDICATOR.
    attr :root

    # Location of project source code. Currently, this is always
    # the same as the root.
    #--
    # TODO: Support alternate source location in the future verison?
    #++
    attr :source

    ## Rock configuration settings. These are found under <tt>.config/rock/</tt>.
    ## Rock settings are a file store like Metadata.
    #
    #def settings
    #  @settings ||= FileStore.new(root, '.config/rock')
    #end

    # Provides access to the PACAKGE metadata file.
    def package
      @package ||= Package.new(root)
    end

    # Provides access to the PROFILE metadata file.
    def profile
      @profile ||= Profile.new(root, :name=>package.name)
    end

    # Provides unified access to all metadata.
    def metadata
      @metadata ||= Metadata.new(root, package, profile)
    end

    # Project name.
    def name
      package.name
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

    # Project manifest. For manifest file use <tt>manifest.file</tt>.
    def manifest
      @manifest ||= Manifest.new(root)
    end

    # Access to project history.
    def history
      @history ||= History.new(root)
    end

    # Access latest release notes.
    def news
      @news ||= News.new(root, :history=>history)
    end

    # S T A N D A R D  D I R E C T O R I E S

    # The <tt>log/</tt> directory stores log output created by 
    # build tools. If you want to publish your logs as part
    # of your website (which might be a very nice thing to do)
    # symlink it into you site location.
    #
    # Get pathname of given log +path+. Or without +path+
    # returns the pathname for the log directory.
    def log(path=nil)
      if path
        log + path
      else
        @log ||= root + 'log'
      end
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
        @doc ||= root + 'doc'
      end
    end

    # Returns the pathname for the package directory.
    # With +path+ returns the pathname within the pacakge path.
    def pkg(path=nil)
      if path
        pkg + path
      else
        @pkg ||= root.first('{pkg,pack,package}{,s}') || root + 'pkg'
      end
      #@pkg ||=(
      #  dir = root.glob_first('{pack,pkg}{,s}') || 'pack'
      #  dir.mkdir_p unless dir.exist?
      #  dir
      #)
    end

    # Alias for #pkg.
    alias_method :pack, :pkg

    # The <tt>.cache/</tt> directory is used by build tools to
    # store temporary files. For instance, the +rock+ command uses
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
        @cache ||= root + '.cache'
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
        @config ||= root.first('{.,}config') || root + '.config'
      end
    end

    # The <tt>plug/</tt> directory serves the same purpose as 
    # the <tt>lib/</tt> directory. It simply provides a place
    # to put plugins separate from the main <tt>lib/</tt> files.
    #
    # Get pathname of given plugin +path+. Or without +path+
    # returns the pathname for the plugin directory.
    #
    # TODO: This assumes lib/ is in the load path, and is used
    # to house plugin/. This is of course typical. However it is
    # possible to alter the load path. So it may not always be the
    # case. In the future, it must be decided if we should standardize
    # around the lib/ convention (though you could still add others to
    # the load path) or allow it to be complete free form. As I did for
    # bin/, I prefer the former, but have not yet firmly decided.
    def plugin(path=nil)
      if path
        plugin + path
      else
        @plugin ||= root.first('lib/plugins') || root + 'lib/plugins'
      end
    end

    #
    alias_method :plugins, :plugin

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
        @script ||= root + 'script'
      end
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

    # Not strickly a project directory. THis provides a temporary
    # system location outside the project directory.
    # 
    # Get pathname of given temporary +path+. Or without +path+
    # returns the pathname to the temporary directory.
    #--
    # TODO: Add name to end of path ?
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

    # Returns list of executable files in bin/.
    def executables
      root.glob('bin/*').select{ |bin| bin.executable? }.map{ |bin| File.basename(bin) }
    end

    # List of extension configuration scripts.
    # These are used to compile the extensions.
    def extensions
      root.glob('ext/**/extconf.rb')
    end

    #
    def compiles?
      !extensions.empty?
    end

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
          list << "* home: #{metadata.resources.home}\n" if metadata.resources.home
          list << "* work: #{metadata.resources.work}\n" if metadata.resources.work
          list << "* docs: #{metadata.resources.docs}\n" if metadata.resources.docs
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
          if file = Dir.glob(README, File::FNM_CASEFOLD).first
            readme  = File.read(file).strip
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

  end#class Project

end#module Rock

