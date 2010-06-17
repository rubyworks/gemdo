module POM

  class Project

    # Require RubyGems library.
    def require_rubygems
      begin
        require 'rubygems' #/specification'
        #::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed."
      end
    end

    # Create a Gem::Specification
    def to_gemspec(options={})
      require_rubygems

      if md = /(\w+).rubyforge.org/.match(profile.homepage)
        rubyforge_project = md[1]
      else
        rubyforge_project = metadata.name  # b/c it has to be something according to Eric Hodel.
      end

      ::Gem::Specification.new do |spec|
        spec.name          = self.name
        spec.version       = self.version
        spec.require_paths = self.loadpath

        spec.summary       = profile.summary
        spec.description   = profile.description
        spec.authors       = profile.authors
        spec.email         = profile.email

        spec.homepage      = profile.homepage

        # -- platform --

        # TODO: how to handle multiple platforms?
        spec.platform = options[:platform] #|| verfile.platform  #'ruby' ???
        #if metadata.platform != 'ruby'
        #  spec.require_paths.concat(spec.require_paths.collect{ |d| File.join(d, platform) })
        #end

        # -- rubyforge project --

        spec.rubyforge_project = rubyforge_project

        # -- compiled extensions --

        spec.extensions = options[:extensions] || self.extensions

        # -- dependencies --

        case options[:gemfile]
        #when String
        #  gemfile = root.glob(options[:gemfile]).first  # TODO: Alternate gemfile
        when nil, true
          gemfile = root.glob('Gemfile').first
        else
          gemfile = nil
        end

        if gemfile
          require 'bundler'
          spec.add_bundler_dependencies

        elsif requires.file
          requires.dependencies.each do |dep|
            if dep.development?
              spec.add_development_dependency( *[dep.name, dep.constraint].compact )
            else
              next if dep.optional?
              spec.add_runtime_dependency( *[dep.name, dep.constraint].compact )
            end
          end

        end

        # TODO: considerations?
        #spec.requirements = options[:requirements] || package.consider

        # -- executables --

        # TODO: bin/ is a POM convention, is there are reason to do otherwise?
        spec.bindir      = options[:bindir]      || "bin"
        spec.executables = options[:executables] || self.executables

        # -- rdocs (argh!) --

        readme = root.glob_relative('README{,.*}', File::FNM_CASEFOLD).first
        extra  = options[:extra_rdoc_files] || []

        rdocfiles = []
        rdocfiles << readme.to_s if readme
        rdocfiles.concat(extra)
        rdocfiles.uniq!

        rdoc_options = [] #['--inline-source']
        rdoc_options.concat ["--title", "#{metadata.title} API"] #if metadata.title
        rdoc_options.concat ["--main", readme.to_s] if readme

        spec.has_rdoc         = true  # always true
        spec.extra_rdoc_files = rdocfiles
        spec.rdoc_options     = rdoc_options

        # -- distributed files --

        if manifest.exist?
          filelist = manifest.select{ |f| File.file?(f) }
          spec.files = filelist
        else
          spec.files = root.glob_relative("**/*").map{ |f| f.to_s } # metadata.distribute ?
        end

        # -- test files --

        # TODO: Improve. Make test_files configurable (?)
        spec.test_files = manifest.select do |f|
          File.basename(f) =~ /test/ && File.extname(f) == '.rb'
        end
      end

    end

    # Build a POM project using a gemspec. This is intended to make it
    # farily easy to build a set of POM meta/ files if you already have
    # a gemspec.
    def import_gemspec(gemspec=nil)
      gemspec = gemspec || self.gemspec

      package.name         = gemspec.name
      package.version      = gemspec.version.to_s
      package.path         = gemspec.require_paths
      #package.arch        = gemspec.platform

      profile.title        = gemspec.name.capitalize
      profile.summary      = gemspec.summary
      profile.description  = gemspec.description
      profile.authors      = gemspec.authors
      profile.contact      = gemspec.email

      profile.resources.homepage = gemspec.homepage

      #metadata.extensions   = gemspec.extensions

      gemspec.dependencies.each do |d|
        next unless d.type == :runtime
        requires << "#{d.name} #{d.version_requirements}"
      end
    end

  end#class Project

end#module POM

