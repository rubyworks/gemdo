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

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom spec"

        opt.on("--update", "-u", "update .prospec file") do
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

    #
    def execute
      if @update
        project.profile.save!
        puts "Project .prospec file updated."
      else
        puts project.metadata.to_h.to_yaml
      end
    end

  end

end

