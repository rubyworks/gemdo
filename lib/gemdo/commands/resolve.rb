module Gemdo::Commands

  #
  class Resolve

    def self.run
      new.run
    end

    #
    def run
      require 'gemdo/resolver'
      @options = {}
      parse
      execute
    end

    #
    attr :options

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "gemdo resolve"
        opt.on("--runtime", "-r", "runtime dependencies only") do
          @options[:runtime] = true
        end
        opt.on("--prerelease", "-p", "include prerleases") do
          @options[:prerelease] = true
        end
        opt.on("--local", "resolve against local sources") do
          @options[:local] = true
        end
        opt.separator("FORMAT OPTIONS: (pick one)")
        opt.on("--lock", "output lock code") do
          @options[:format] = :lock
        end
        #opt.on("--requests", "--req", "show all dependencies") do
        #  @options[:format] = :requests
        #end
        opt.on("--breakdown", "-b", "show all dependencies") do
          @options[:format] = :breakdown
        end
        opt.separator("COMMON OPTIONS:")
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
      resolver = Gemdo::Resolver.new(Dir.pwd, options)
      resolver.setup
    end

    #
    #def project
    #  @project ||= Gemdo::Project.new(Dir.pwd)
    #end

    # OLD SCHOOL
    #def execute
    #  project.requirements.each do |req|
    #    begin
    #    #  $stdout.print(" " * depth)
    #      gem(req.name, req.constraint.to_s)
    #    rescue Exception => error
    #      $stdout.puts "  [FAIL] %-20s %s" % [req.to_s, error.to_s.strip]
    #    else
    #      $stdout.puts "  [LOAD] #{req}"
    #    end
    #  end
    #end
  end

end

