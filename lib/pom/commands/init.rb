module POM::Commands

  class Init

    def self.run
      new.run
    end

    #
    def initialize
      #@project = POM::Project.new(:lookup=>true)
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
        opt.banner = "pom init [RESOURCE ...]"

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

      require 'pom/metadata'
      require 'pom/readme'
      require 'pom/models/gemspec'

      #prime = { 
      #  'name'       => File.basename(Dir.pwd),
      #  'version'    => '0.0.0',
      #  'requires'   => [],
      #  'summary'    => "FIX: brief one line description here",
      #  'contact'    => "FIX: name <email> or uri",
      #  'authors'    => "FIX: names of authors here",
      #  'repository' => "FIX: master public repo uri"
      #}

      project = POM::Project.new(Dir.pwd)

      #exists = Dir.glob('{.,}meta').first

      if project.profile.file and not $FORCE
        $stderr << "Profile already exists. Use --force option to allow overwrite.\n"
        return
      end

      if project.verfile.file and not $FORCE
        $stderr << "Version file already exists. Use --force option to allow overwrite.\n"
        return
      end

      # prime
      project.verfile.name     = File.basename(Dir.pwd)
      project.verfile.version  = '0.0.0'
      project.verfile.code     = 'FIXME: A version code name is optional'

      project.profile.summary = "FIXME: brief one line description here"
      project.profile.contact = "FIXME: name <email> or uri"
      project.profile.authors << "FIXME: list of author's names here"

      project.profile.resources.homepage   = "FIXME: main website address"
      project.profile.resources.repository = "FIXME: master public repo uri"

      #metadata.new_project

      files = resources()
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
          readme = POM::Readme.load(file)
          project.import_readme(readme)
        else
          text = File.read(file)
          obj  = /^---/.match(text) ? YAML.load(text) : text
          case obj
          when ::Gem::Specification
            project.import_gemspec(obj)
          when String
            project_import_readme(obj)
          #when Hash
            #metadata.mesh(obj)
          else
            puts "Cannot convert #{file} (skipped)"
          end
        end
      end

      #project.root = Dir.pwd

      # load any meta entries that may already exist
      #project.reload unless options[:replace]

      unless $TRIAL
        project.verfile.backup!
        project.verfile.save!

        project.profile.backup!
        project.profile.save!
      end

      print_fixes
    end

    #
    def print_fixes
      fixes = []
      pwd = Pathname.new(Dir.pwd)
      paths = POM::Verfile.filename + POM::Profile.filename
      paths.each do |path|
        pwd.glob(path).each do |file|
          File.readlines(file).each{ |l| l.grep(/FIXME:/).each{ |r| fixes << file.relative_path_from(pwd) } }
        end
      end
      fixes.uniq!
      unless fixes.empty?
        puts "The following files require editing:\n"
        puts "  " + fixes.join("\n  ")
      end
    end

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
