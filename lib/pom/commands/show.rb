module POM::Commands

  # Show a given setting of the project's metadata.
  class Show

    def self.run
      new.run
    end

    #
    attr :project

    #
    attr :entry

    #
    def initialize
      @project = POM::Project.find
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom show [ENTRY]"

        opt.on("--debug", "run in debug mode") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!

      @entry = ARGV.last
    end

    #
    def execute
      if entry
        puts project.profile[entry]
      else
        vars = project.profile.attributes
        puts vars.sort.join(' ')
      end
    end

  end

end

