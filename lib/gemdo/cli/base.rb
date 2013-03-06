module GemDo
module CLI

  # Base class for GemDo commands.
  class Base

    #
    def self.inherited(subclass)
      Commands << subclass
    end

    #
    def self.run
      new.run
    end

    #
    def initialize
      $TRIAL = nil
      $FORCE = nil

      @options   = OpenStruct.new
      @arguments = []
    end

    # Access to Project instance.
    def project
      @project ||= Project.find
    end

    #
    attr :options

    #
    attr :arguments

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser.parse!
      @arguments = ARGV
    end

    #
    def parser(&block)
      @parser ||= (
        opt = OptionParser.new(&block)

        opt.on("--debug", "run in debug mode") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end

        opt
      )
    end

    def self.run
      new.run
    end

  end#class Base

end#module Commands

end
end
