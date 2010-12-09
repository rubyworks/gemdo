module POM::Commands

  # Generate a Rubyspec YAML file from a Rubyfile script.
  class Rubyspec

    #
    def self.run
      new.run
    end

    #
    def initialize
      require 'pom/project'

      @project  = POM::Project.new(:lookup=>true)
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
        opt.banner = "pom gemspec"

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
      if File.exist?(@project.gemfile.file)
      #if File.exist?(file) and not $FORCE
      #  $stderr << "Rubyspec already exists. Use --force to overwrite.\n"
      #else

        data = @project.profile.to_h.merge(@project.gemfile.to_h)
        spec = POM::Rubyspec.new(@project.root, data)

        spec.save!

        puts "#{spec.file.relative_path_from(Pathname.new(Dir.pwd))} updated."
        #yaml = project.to_gemspec.to_yaml
        #File.open(file, 'w') do |f|
        #  f << yaml
        #end
      else
        puts "No Gemfile found."
      end
    end

    #
    #def file
    #  project.rubyspec.file
    #end

  end

end

