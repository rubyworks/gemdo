module POM::Commands

  # Convert pom spec into a gemspec.
  #
  # TODO: Use canonical by default and add option to update canoncial first.
  # Or something along those lines.
  class Gemspec

    #
    def self.run
      new.run
    end

    #
    def initialize
      require 'pom/gemspec'
      @project = POM::Project.find
    end

    #
    attr :project

    #
    def update?
      @update
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom gemspec"

        opt.on("--update", "-u", "update gemspec file") do
          @update = true
        end

        opt.on("--force", "-f", "override any safe-guarded operations") do
          $FORCE = true
        end

        opt.on("--debug", "run in debug mode and raise exceptions") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!

      @file = ARGV.first
    end

    #
    def execute
      yaml = project.to_gemspec.to_yaml
      if update?
        #if File.exist?(file) and not $FORCE
        #  $stderr << "Gemspec already exists. Use --force/-f to overwrite.\n"
        #else
          File.open(file, 'w') do |f|
            f << yaml
          end
          $stderr.puts "#{File.basename(file)} updated."
        #end
      else
        $stdout.puts yaml
      end
    end

    #
    def file
      @file ||= (
        dot_gemspec = (project.root + '.gemspec').to_s
        if File.exist?(dot_gemspec)
          dot_gemspec.to_s
        else
          project.metadata.name + '.gemspec'
        end
      )
    end

  end

end

