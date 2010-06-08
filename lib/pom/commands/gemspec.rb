module POM::Commands

  class Gemspec

    #
    def self.run
      new.run
    end

    #
    def initialize
      require 'pom/gemspec'
      @project = POM::Project.new(:lookup=>true)
    end

    #
    attr :project

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom gemspec"

        opt.on("--force", "-f", "override safe-guarded operations") do
          $FORCE = true
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
    end

    #
    def execute
      if File.exist?(file) and not $FORCE
        $stderr << "Gemspec already exists. Use --force to overwrite.\n"
      else
        yaml = project.to_gemspec.to_yaml
        File.open(file, 'w') do |f|
          f << yaml
        end
      end
    end

    #
    def file
      project.metadata.name + '.gemspec'
    end

  end

end

