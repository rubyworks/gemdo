module POM::Commands

  class Dump

    def self.run
      new.run
    end

    attr :project

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
        opt.banner = "pom dump"

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!
    end

    #
    def execute
      puts project.metadata.to_yaml
    end

  end

end

