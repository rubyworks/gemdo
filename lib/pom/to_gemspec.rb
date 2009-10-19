module POM

  class Project

    # Create a Gem::Specification
    #
    # NOTE: This would be a method of METADATA except that it needs
    # the manifest list, which is in Project. Perhaps this indicates
    # that the Manifest should be a part of the Metadata?
    #
    def to_gemspec(options={})

      # Make sure RubyGems is loaded.
      begin
        Kernel.require 'rubygems/specification'
        ::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed?"
      end

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

        if metadata.require
          metadata.require.each do |d,v|
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

        readme = Dir.glob('README{,.txt}', File::FNM_CASEFOLD).first

        spec.has_rdoc = true  # always true

        if options[:extra_rdoc_files]
          rdocfiles = []
          rdocfiles << readme if readme
          rdocfiles.concat = options[:extra_rdoc_files]
        else
          rdocfiles = []
          rdocfiles << readme if readme
          rdocfiles.concat(Dir['[A-Z]*'] || [])  # metadata.document
          rdocfiles.uniq!
        end
        spec.extra_rdoc_files = rdocfiles

        rdoc_options = [] #['--inline-source']
        rdoc_options.concat ["--title", "#{metadata.title} API"] #if metadata.title
        rdoc_options.concat ["--main", readme] if readme
        spec.rdoc_options = rdoc_options

        # -- distributed files --

        spec.files = manifest.files

        # -- test files --

        # TODO: make test_files configurable (?)
        spec.test_files = distribute.select do |f|
          File.basename(f) =~ /test/ && File.extname(f) == '.rb'
        end
      end

    end

  end#class Project

end#module POM

