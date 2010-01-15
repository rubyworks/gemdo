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

    #
    def execute
      require_rubygems

      require 'pom/metadata'
      require 'pom/readme'
      require 'pom/models/gemspec'

      exists = Dir.glob('{.,}meta').first

      if exists and not $FORCE
        $stderr << "A #{exists} directory already exists. Use --force option to allow overwrite.\n"
        return
      end

      files = resources()

      if files.empty?
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      metadata = POM::Metadata.new(Dir.pwd)
      metadata.new_project

      files.each do |file|
        text = File.read(file)
        obj  = /^---/.match(text) ? YAML.load(text) : text
        case obj
        when ::Gem::Specification
          metadata.mesh(POM::Metadata.from_gemspec(obj))
        when String
          metadata.mesh(POM::Metadata.from_readme(obj))
        when Hash
          metadata.mesh(obj)
        else
          puts "Skipping #{obj.class} cannot be converted into Metadata."
        end
      end

      # load any meta entries that may already exist
      metadata.reload unless options[:replace]

      metadata.backup! unless $TRIAL
      metadata.save!   unless $TRIAL

      fixes = []
      pwd = Pathname.new(Dir.pwd)
      metadata.paths.each do |path|
        path.glob('*').each do |file|
          File.readlines(file).each{ |l| l.grep(/FIX:/).each{ |r| fixes << file.relative_path_from(pwd) } }
        end
      end
      if !fixes.empty?
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
