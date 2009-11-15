module POM::Commands

  class Init

    def self.run
      new.run
    end

    #
    def initialize
      #@project = POM::Project.new(:lookup=>true)
    end

    #
    attr :resources

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom init [RESOURCE ...]"

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
      require 'pom/metadata'
      require 'pom/readme'
      require 'pom/models/gemspec'

      exists = Dir.glob('{.,}meta').first

      if exists and not $FORCE
        $stderr << "A #{exists} directory already exists. Use --force option to allow overwrites.\n"
        return
      end

      files = resources()

      if files.empty?
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      metadata = POM::Metadata.new
      metadata.load_defaults

      files.each do |file|
        text = File.read(file)
        obj  = /^---/.match(text) ? YAML.load(text) : text
        case obj
        when ::Gem::Specification
          metadata.mesh( POM::Metadata.from_gemspec(obj) )
        when String
          metadata.mesh( POM::Metadata.from_readme(obj) )
        when Hash
          metadata.mesh( obj )
        else
          puts "Skipping #{obj.class} cannot be converted into Metadata."
        end
      end

      metadata.load    # load any meta entries that may alread exist

      metadata.backup! unless $TRIAL
      metadata.save!   unless $TRIAL
    end

  end

end

