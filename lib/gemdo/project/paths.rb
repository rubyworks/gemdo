module GemDo

  class Project

    ##
    # Locations of typical project directories.
    #
    # This is handled via delegation in order to provide a 
    # cleaner interface.
    #
    class Paths

      # Initialize Paths instance.
      def initialize(project)
        @project = project
      end

      # Location of project source code. Currently, this is always
      # the same as the root.
      #
      # @return [Pathname]
      def root
        @project.root
      end

      # Alias for +root+.
      #
      # @todo Support alternate source location in the future verison?
      alias src root
      alias source root

      # The bin directory is the place to keep executables.
      #
      # Get pathname of given bin `path`. Or without `path`
      # returns the pathname for the bin directory.
      #
      # @return [Pathname]
      def bin(path=nil)
        if path
          doc + path
        else
          @doc ||= root + 'bin'
        end
      end

      # The ext directory is the place to keep extensions, typically
      # written in C.
      #
      # Get pathname of given doc `path`. Or without `path`
      # returns the pathname for the doc directory.
      #
      # @return [Pathname]
      def ext(path=nil)
        if path
          doc + path
        else
          @doc ||= root + 'ext'
        end
      end

      # The doc directory is the place to keep documentation. The directory
      # is intended to be distributed with a package, but this is not often
      # done these days since RubyGems generates RDocs on demand, and
      # documentation is often found online.
      #
      # Get pathname of given doc `path`. Or without `path`
      # returns the pathname for the doc directory.
      #
      # @return [Pathname]
      def doc(path=nil)
        if path
          doc + path
        else
          @doc ||= root + 'doc'
        end
      end

      # The <tt>log/</tt> directory stores log output created by 
      # build tools. If you want to publish your logs as part
      # of your website (which might be a very nice thing to do)
      # symlink it into you site location.
      #
      # Get pathname of given log +path+. Or without +path+
      # returns the pathname for the log directory.
      #
      # @return [Pathname]
      def log(path=nil)
        if path
          log + path
        else
          @log ||= root + 'log'
        end
      end

      # Returns the pathname for the package directory.
      # With +path+ returns the pathname within the pacakge path.
      #
      # @return [Pathname]
      def pkg(path=nil)
        if path
          pkg + path
        else
          @pkg ||= root.first('{pkg,pack,package}{,s}') || root + 'pkg'
        end
      end

      # The `tmp/` or `.cache/` directory is used by build tools to
      # store temporary files. For instance, the +pom+ command uses
      # it to store backups of metadata entries when overwriting
      # old entries. <tt>.cache/</tt> should be in your SCM's
      # ignore list.
      #
      # Get pathname of given cache +path+. Or without +path+
      # returns the pathname for the cache directory.
      #
      # @return [Pathname]
      def cache(path=nil)
        if path
          cache + path
        else
          @cache ||= root.first('tmp,.cache') || root + 'tmp'
        end
      end

      # Alias for #cache.
      alias tmp cache

      # The directory for for build tools to place their configration
      # files. It is either `.config/`, `.etc/`, `config/` or `etc/`,
      # matched in that order of precednece.
      #
      # Pathname of given config +path+. Or without `path`
      # Returns the path to the config directory (either `.etc`
      # or `etc`).
      #
      # @return [Pathname]
      def config(path=nil)
        if path
          config + path
        else
          @config ||= root.first('{.config,.etc,config,etc}') || root + 'etc'
        end
      end

      alias etc config

=begin
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
=end

      # The `script/` directory is like the <tt>task/</tt> 
      # directory but usually holds executables that are made
      # available to the end-installers.
      #
      # Get pathname of given script +path+. Or without +path+
      # returns the pathname for the script directory.
      #
      # @return [Pathname]
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
      #
      # @deprecated Using tasks/ has become rather passe.
      #
      # @return [Pathname]
      def task(path=nil)
        if path
          task + path
        else
          @task ||= root.first('{task,tasks}') || root+'task'
        end
      end

      # The `site/`, `web/` or `website/` directory is
      # where a project's website files are stored.
      #
      # Get pathname of given site `path`. Or without +path+
      # returns the pathname for the site directory.
      #
      # @return [Pathname]
      def website(path=nil)
        if path
          site + path
        else
          @site ||= root.first('{site,web,website}') || root + 'web'
        end
      end

      # Alias for #website.
      alias web website
      alias site website

      # This provides a temporary system location outside the
      # project directory.
      # 
      # Get pathname of given temporary `path`. Or without `path`
      # returns the pathname to the temporary directory.
      #
      # @todo Add project name to end of path?
      #
      # @return [Pathname]
      def systmp(path=nil)
        if path
          systmp + path
        else
          @systmp ||= Pathname.new(Dir.tmpdir)
        end
      end

    private

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
      # @return [Boolean]
      #   true if directory exists, otherwise false.
      def directory?(path)
        root.join(path).directory?
      end

    end

  end

end
