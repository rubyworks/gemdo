module Gemdo::Commands

  class Init

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

      #has_package = Gemdo::Package.find(root)
      #has_profile = Gemdo::Profile.find(root)
      #has_rubydir = Gemdo::RubyDir.find(root)

      #if Gemdo::Package.find(root) and not $FORCE
      #  $stderr << "PACKAGE file already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      #if Gemdo::Profile.find(root) and not $FORCE
      #  $stderr << "PROFILE already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      if !File.exist?('.ruby')
        File.open('.ruby', 'w'){|f| f << ""}
      end

      has_package = Gemdo::Package.find(root)
      has_profile = Gemdo::Profile.find(root)

      if (has_package || has_profile) && !$FORCE
        $stderr.puts "Looks like your project is already built on a gemdo."
        $stderr.puts "To re-create the metadata files use the --force option."
        return
      end

      #name = File.basename(root)

      project = Gemdo::Project.new(root)

      name = project.name || File.basename(root)

      #profile = Gemdo::Profile.new(root, name)

      metadata = project.metadata

      if !has_package
        #metadata.new_project
        metadata.name     = File.basename(root)
        metadata.version  = '0.0.0'
        metadata.codename = 'FIXME A version codename is optional'
      end

      if !has_profile
        metadata.summary  = "FIXME brief one line description here"
        metadata.contact  = "FIXME name <#{ENV['EMAIL']}>"
        metadata.authors << "FIXME list of author's names here"
        metadata.resources.homepage   = "FIXME: http://your_website.org"
        metadata.resources.repository = "FIXME: master public repo uri"
      end

      files = resources

      if files.empty?
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      files.each do |file|
        case file
        when /\.gemspec$/
          text = File.read(file)
          gemspec = /^---/.match(text) ? YAML.load(text) : Gem::Specification.load(file)
          project.import_gemspec(gemspec)
        when /^README/i
          readme = Gemdo::Readme.load(file)
          project.import_readme(readme)
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

      #project.root = root

      # load any meta entries that may already exist
      #project.reload unless options[:replace]

      #package_file = package.file ? package.file : File.join(root,'PACKAGE')
      #profile_file = profile.file ? profile.file : File.join(root,'PROFILE')

      if $TRIAL
      else
        #if $FORCE or !(has_package or has_profile)
          metadata.backup!
          metadata.save! #(package_file)
        #end
      end

      puts "The following files were created or updated and should be edited:\n"
      puts "  PACKAGE"
      puts "  PROFILE"
    end

    #
    #def print_fixes
    #  root  = Dir.pwd
    #  fixes = []
    # pwd = Pathname.new(root)
    #  files = [Gemdo::Package.find(root), Gemdo::Profile.find(root)]
    #  files.each do |file|
    #    File.readlines(file).each{ |l| l.grep(/FIXME/).each{ |r| fixes << file.relative_path_from(pwd) } }
    #  end
    #  fixes.uniq!
    #  unless fixes.empty?
    #    puts "The following files require editing:\n"
    #    puts "  " + fixes.join("\n  ")
    #  end
    #end

    #
    def require_rubygems
      begin
        require 'rubygems'
        #::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed."
      end
    end

  end

end
