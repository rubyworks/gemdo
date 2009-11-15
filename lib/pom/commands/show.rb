module POM::Commands

  class Show

    def self.run
      new.run
    end

    attr :project

    attr :entry

    def initialize
      @project = POM::Project.new(:lookup=>true)
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
        puts project.metadata.send(entry)
      else
        puts project.metadata.keys.join(' ')
      end
    end

  end

end
