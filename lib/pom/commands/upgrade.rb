module POM::Commands
  require 'pom/metadir'
  require 'pom/profile'
  require 'pom/package'

  #
  class Upgrade

    def self.run
      new.run
    end

    #
    def initialize
      #@project = POM::Project.new(:lookup=>true)
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom upgrade"

        opt.on("--debug", "run in debug mode") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on("--force", "overwrite pre-existing PACKAGE/PROFILE files") do
          $FORCE = true
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
      if File.exist?('PROFILE') or File.exist?('PACKAGE')
        abort "use --force to overwrite PACKAGE and PROFILE files" unless $FORCE
      end
      metadir = POM::Metadir.new('.')
      if metadir.store
        profile = metadir.to_profile
        package = metadir.to_package
        profile.save!('PROFILE')
        package.save!('PACKAGE')
        puts "Please edit the PACKAGE and PROFILE files."
      else
        puts "No meta directory found to convert."
      end
    end

  end

end

