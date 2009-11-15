module POM

  class Project

    # Require RubyGems library.
    #
    def require_rubygems
      begin
        require 'rubygems/specification'
        #::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed."
      end
    end

    # Create a Gem::Specification
    #
    # NOTE: This would be a method of METADATA except that it needs
    # the manifest list, which is in Project. Perhaps this indicates
    # that the Manifest should be a part of the Metadata?
    #
    def to_gemspec(options={})
      require_rubygems

      # FIXME: this only works b/c of package staging
      #distribute = Dir.glob('**/*')
      #distribute = project.filelist
      #distribute = manifest #.files

      if md = /(\w+).rubyforge.org/.match(metadata.homepage)
        rubyforge_project = md[1]
      else
        rubyforge_project = metadata.name  # b/c it has to be something according to Eric Hodel.
      end

      ::Gem::Specification.new do |spec|
        spec.name          = metadata.name
        spec.version       = metadata.version
        spec.summary       = metadata.summary
        spec.description   = metadata.description
        spec.authors       = [metadata.authors].flatten.compact.uniq
        spec.email         = metadata.contact #metadata.email
        spec.homepage      = metadata.homepage
        spec.require_paths = [metadata.loadpath].flatten

        # -- platform --

        spec.platform = options[:platform] || metadata.platform  #'ruby' ???
        #if metadata.platform != 'ruby'
        #  spec.require_paths.concat(spec.require_paths.collect{ |d| File.join(d, platform) })
        #end

        # -- rubyforge project --

        spec.rubyforge_project = rubyforge_project

        # -- compiled extensions --

        spec.extensions = [metadata.extensions].flatten.compact

        # -- dependencies --

        if metadata.requires
          metadata.requires.each do |d,v|
            d,v = *d.split(/\s+/) unless v
            spec.add_dependency(*[d,v].compact)
          end
        end

        spec.requirements = options[:requirements] || metadata.notes

        # -- executables --

        # TODO: bin/ is a POM convention, is there are reason to do otherwise?
        spec.bindir      = options[:bindir]      || "bin"
        spec.executables = options[:executables] || metadata.executables

        # -- rdocs (argh!) --

        readme = root.glob_relative('README{,.txt}', File::FNM_CASEFOLD).first

        spec.has_rdoc = true  # always true

        extra_rdoc_files = options[:extra_rdoc_files] || (root.glob_relative('[A-Z]*') || []).map{ |path| path.to_s }

        rdocfiles = []
        rdocfiles << readme.to_s if readme
        rdocfiles.concat(extra_rdoc_files)
        rdocfiles.uniq!

        spec.extra_rdoc_files = rdocfiles

        rdoc_options = [] #['--inline-source']
        rdoc_options.concat ["--title", "#{metadata.title} API"] #if metadata.title
        rdoc_options.concat ["--main", readme.to_s] if readme
        spec.rdoc_options = rdoc_options

        # -- distributed files --

        if manifest.exist?
          spec.files = manifest.select{ |f| File.file?(f) }          
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

  end

  class Metadata

    # Build a POM project using a gemspec. This is intended to make it
    # farily easy to build a set of POM meta/ files if you already have
    # a gemspec.
    #
    def self.from_gemspec(gemspec, root=Dir.pwd)
      metadata = Metadata.load(root)

      metadata.name         = gemspec.name
      metadata.version      = gemspec.version.to_s
      metadata.summary      = gemspec.summary
      metadata.description  = gemspec.description
      metadata.authors      = gemspec.authors
      metadata.contact      = gemspec.email
      metadata.homepage     = gemspec.homepage
      metadata.loadpath     = gemspec.require_paths

      metadata.platform     = gemspec.platform

      metadata.extensions   = gemspec.extensions

      requires = []
      gemspec.dependencies.each do |d|
        next unless d.type == :runtime
        requires << "#{d.name} #{d.version_requirements}"
      end
      metadata.requires = requires

      metadata
    end

  end#class Project

end#module POM

