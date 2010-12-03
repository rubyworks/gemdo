module Gemdo::Commands

  #
  class Dump

    def self.run
      new.run
    end

    attr :project

    def initialize
      @project = Gemdo::Project.new(:lookup=>true)
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "gemdo dump"

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
    end

    #
    def execute
      puts project.rubyspec.yaml
    end

  end

end

