module POM::Commands

  #
  class Spec

    def self.run
      new.run
    end

    attr :project

    def initialize
      @project = POM::Project.find
      @update  = false
    end

    #
    def run
      parse
      execute
    end

    # TODO: reference constant for .ruby file
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom spec"

        opt.on("--update", "-u", "update .ruby file") do
          @update = true
        end

        opt.on("--debug", "run in debug mode") do
          $DEBUG = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!
    end

    # TODO: Maybe make file name printout relative to current directory.
    def execute
      if @update
        file = project.profile.save!
        $stdout.puts "#{File.basename(file)} updated."
      else
        $stdout.puts project.metadata.to_data.to_yaml
      end
    end

  end

end

