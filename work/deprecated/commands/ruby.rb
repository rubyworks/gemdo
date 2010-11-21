module Gemdo::Commands

  class Dotruby

    def self.run
      new.run
    end

    #
    def initialize
      #@project = Gemdo::Project.new(:lookup=>true)
      @options = {}
    end

    #
    attr :resources
    attr :options

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "gemdo init [RESOURCE ...]"

        opt.on("--replace", "-r", "replace any pre-existing entries") do
          options[:replace] = true
        end

        opt.on("--force", "-f", "override safe-guarded operations") do
          $FORCE = true
        end

        opt.on("--trial", "run in trial mode, skips disk writes") do
          $TRIAL = true
        end

        opt.on("--debug", "run in debug mode, raises exceptions") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!

      @resources = ARGV
    end

    #--
    # TODO: How to handle options[:replace] ?
    #++
    def execute
      require_rubygems

      require 'gemdo/metadata'
      require 'gemdo/readme'
      require 'gemdo/gemspec'

      root = Dir.pwd

      #prime = { 
      #  'name'       => File.basename(root),
      #  'version'    => '0.0.0',
      #  'requires'   => [],
      #  'summary'    => "FIX brief one line description here",
      #  'contact'    => "FIX name <email> or uri",
      #  'authors'    => "FIX names of authors here",
      #  'repository' => "FIX master public repo uri"
      #}

      has_package = Gemdo::Package.find(root)
      has_profile = Gemdo::Profile.find(root)
      has_rubydir = Gemdo::RubyDir.find(root)

      #if Gemdo::Package.find(root) and not $FORCE
      #  $stderr << "PACKAGE file already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      #if Gemdo::Profile.find(root) and not $FORCE
      #  $stderr << "PROFILE already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      project = Gemdo::Project.new(root) #, :name=>name)
      rubydir = Gemdo::RubyDir.new(root)
      package = Gemdo::Package.new(root)

      name = package.name || File.basename(root)

      profile = Gemdo::Profile.new(root, name)

      if !has_package
        #package.name    = name # ???
        package.version  = '0.0.0'
        package.code     = 'FIXME A version code name is optional'
      end

      if !has_profile
        profile.summary  = "FIXME brief one line description here"
        profile.contact  = "FIXME name <email> or uri"
        profile.authors << "FIXME list of author's names here"

        profile.resources.homepage   = "FIXME: main website address"
        profile.resources.repository = "FIXME: master public repo uri"
      end

      #metadata.new_project

      files = resources()
      if files.empty? &&
        if !has_package
          files << Dir.glob('*.gemspec').first if rubygems?
          files << Dir.glob('README{,.*}').first
        else
          files << 'PACKAGE'
        end
      end

      files.compact!

      files.each do |file|
        case file
        when /\.gemspec$/
          if rubygems?
            text = File.read(file)
            gemspec = /^---/.match(text) ? YAML.load(text) : Gem::Specification.load(file)
            project.import_gemspec(gemspec)
          else
            raise "Could not load RubyGems."
          end
        when /^README/i
          readme = Gemdo::Readme.load(file)
          project.import_readme(readme)
        when /^PACKAGE/
          rubydir.load_from_package(package)
        else
          text = File.read(file)
          obj  = /^---/.match(text) ? YAML.load(text) : text
          case obj
          when ::Gem::Specification
            project.import_gemspec(obj)
          when String
            project.import_readme(obj)
          #when Hash
            #metadata.mesh(obj)
          else
            puts "Cannot convert #{file} (skipped)"
          end
        end
      end

      #
      rubydir.load_from_package(package)

      if $TRIAL
      else    
        rubydir.save!
      end
    end

    #
    def rubygems?
      @rubygems
    end

    #
    def require_rubygems
      begin
        require 'rubygems'
        #::Gem::manage_gems
        @rubygems = true
      rescue LoadError
        @rubygems = false
      end
    end

  end

end

