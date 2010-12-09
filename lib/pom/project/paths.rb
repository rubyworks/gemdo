module POM

  class Project

    # Standard Project Directories
    module Paths

      # Location of project source code. Currently, this is always
      # the same as the root.
      #--
      # TODO: Support alternate source location in the future verison?
      #++
      def src
        root
      end

      # Alias for +src+.
      alias_method :source, :src

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

      # Alias for #site.
      alias_method :website, :site

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

      # Does a file exist in the project?
      # Returns the first match.
      def file?(glob)
        Dir.glob(root + glob).first
      end

      # Determines if a directory exists within the project.
      #
      # @param [String] path
      # The path of the directory, relative to the project.
      #
      # @return [Boolean]
      # Specifies whether the directory exists in the project.
      #
      def directory?(path)
        root.join(path).directory?
      end

    end

  end

end
