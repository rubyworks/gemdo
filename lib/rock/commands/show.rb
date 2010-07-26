module Rock::Commands

  class Show

    def self.run
      new.run
    end

    attr :project

    attr :entry

    def initialize
      @project = Rock::Project.new(:lookup=>true)
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "rock show [ENTRY]"

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
        puts project.metadata.__send__(entry)
        #if project.package.respond_to?(entry)
        #  puts project.package.__send__(entry)
        #else
        #  puts project.profile.__send__(entry)
        #end
      else
        vars = project.package.to_h.keys + project.profile.to_h.keys
        puts vars.sort.join(' ')
      end
    end

  end

end

