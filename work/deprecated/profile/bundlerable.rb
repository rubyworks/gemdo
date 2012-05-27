module POM

  class Profile

    # Add some features for compatibility with Bundler Gemfile syntax.
    module Bundlerable

      #
      def initialize_mixins
        @_source   = nil
        @_group    = []
        @_platform = []

        super if defined?(super)
      end

      # Add a requirement.
      def gem(name, *args)
        opts = Hash == args.last ? args.pop : {}

        name, *cons = name.split(/\s+/)

        if md = /\((.*?)\)/.match(cons.last)
          cons.pop
          group = md[1].split(/\s+/)
          opts['group']   = group
        end

        opts['name']    = name
        opts['version'] = cons.join(' ') unless cons.empty?

        opts['source'] ||= @_source if @_source

        unless @_group.empty?
          opts['group'] ||= []
          opts['group'] += @_group
        end

        unless @_platform.empty?
          opts['platform'] ||= []
          opts['plarform'] += @_platform
        end

        profile.add_requirement(opts)
      end

      # --- Bundler Gemfile Compatibility ---

      def source(source) #:yield:
        @_source = source
        yield
      ensure
        @_source = nil
      end

      # For use with defining dependencies with the +gem+ method.
      # This allows for compatibility with Bundler Gemfile.
      def group(*names) #:yield:
        @_group.concat names
        yield
      ensure
        names.each{@_group.pop}
      end

      # This allows for compatibility with Bundler Gemfile.
      def platform(*names) #:yield:
        @_platform.concat names
        yield
      ensure
        names.each{@_platform.pop}
      end

      # Alias for #platform.
      alias_method :platforms, :platform

      # FIXME: Do we need this?
      def path(path, options={}, source_options={}, &blk)
      end

      # This one sucks. Talk about favoring one SCM over another!
      # Handle submodules yourself like a real developer!
      def git(*)
        msg = "The `git` method is incompatible with POM.\n" /
              "Consider using submodules or an alternate tool\n" /
              "to manager vendored sources, and use the `path`\n" \
              "option instead."
        raise msg
      end

      # This one can blow!
      def gemspec(*)
        msg = "The `gemspec` method is incompatible with POM/.\n" /
              "POM will generate a gemspec from the Profile."
        raise msg
      end

      # --- End Bundler Gemfile Compatibility ---

    end

  end

end
