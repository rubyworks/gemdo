require 'gemdo'

module GemDo
module CLI

  # The +about+ command produces a simply console
  # printout of general information about a project.
  class About < Base

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom about"

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
      puts project.about
    end

  end

end
end
