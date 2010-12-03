module Gemdo::Commands

  # Generate a Rubyspec YAML file from a Rubyfile script.
  class Rubyspec

    #
    def self.run
      new.run
    end

    #
    def initialize
      require 'gemdo/project'
      require 'gemdo/rubyfile'
      @project  = Gemdo::Project.new(:lookup=>true)
      @rubyfile = Gemdo::Rubyfile.new(@project.root)
    end

    #
    attr :project

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "gemdo gemspec"

        opt.on("--force", "-f", "override safe-guarded operations") do
          $FORCE = true
        end

        opt.on("--debug", "run in debug mode, raises exceptions") do
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
      if File.exist?(@rubyfile.file)
      #if File.exist?(file) and not $FORCE
      #  $stderr << "Rubyspec already exists. Use --force to overwrite.\n"
      #else
        spec = @rubyfile.to_rubyspec
        spec.save!
        puts "#{spec.file.relative_path_from(Pathname.new(Dir.pwd))} updated."
        #yaml = project.to_gemspec.to_yaml
        #File.open(file, 'w') do |f|
        #  f << yaml
        #end
      else
        puts "No Rubyfile found."
      end
    end

    #
    #def file
    #  project.rubyspec.file
    #end

  end

end

