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
        if project.verfile.respond_to?(entry)
          puts project.verfile.__send__(entry)
        else
          puts project.profile.__send__(entry)
        end
      else
        vars = project.verfile.instance_variables + project.profile.instance_variables
        puts vars.map{ |iv| iv[1..-1] }.sort.join(' ')
      end
    end

  end

end

