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

    # Create a Gem::Specification from a POM::Project. Because POM metadata
    # is extensive a fairly complete a Gem::Specification can be created from
    # it which is sufficient for almost all needs.
    #
    # TODO: However there are still a few features that need address,  such
    # as signatures.
    def to_gemspec(options={})
      require_rubygems

      if metadata.resources
        homepage = metadata.resources.homepage
      else
        homepage = nil
      end

      if homepage && md = /(\w+).rubyforge.org/.match(homepage)
        rubyforge_project = md[1]
      else
        rubyforge_project = metadata.name.to_s  # b/c it has to be something according to Eric Hodel.
      end

      #TODO: may be able to get this from project method
      if news = Dir[root + 'NEWS{,.txt}'].first
        install_message = File.read(news)
      end

      ::Gem::Specification.new do |spec|
        spec.name          = self.name.to_s
        spec.version       = self.version.to_s
        spec.require_paths = self.loadpath.to_a

        spec.summary       = metadata.summary.to_s
        spec.description   = metadata.description.to_s
        spec.authors       = metadata.authors.to_a
        spec.email         = metadata.email.to_s
        spec.licenses      = [metadata.license.to_s]

        spec.homepage      = metadata.homepage.to_s

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
        else
          metadata.requirements.each do |dep|
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

        if install_message
          sepc.post_install_message = install_message
        end
      end

    end

    # Import a Gem::Specification into a POM::Project. This is intended to make it
    # farily easy to build a set of POM metadata files from pre-existing gemspec.
    def import_gemspec(gemspec=nil)
      gemspec = gemspec || self.gemspec

      package.name          = gemspec.name
      package.version       = gemspec.version.to_s
      package.path          = gemspec.require_paths
      #metadata.arch        = gemspec.platform

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

