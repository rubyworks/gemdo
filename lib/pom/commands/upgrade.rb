module POM::Commands
  require 'pom/deprecate/metadir'
  require 'pom/metadata'

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
      if %w{PROFILE PACKAGE REQUIRE}.any?{ |f| File.exist?(f) }
        abort "Use --force to overwrite PACKAGE, PROFILE and/or REQUIRE files." unless $FORCE
      end
      metadir = POM::Metadir.new('.')
      if metadir.store
        profile = metadir.to_profile
        package = metadir.to_package
        require = metadir.to_require
        profile.save!('PROFILE')
        package.save!('PACKAGE')
        require.save!('REQUIRE')
        puts "Please edit the PACKAGE, PROFILE and REQUIRE files."
      else
        $stderr.puts "No meta directory found to convert."
      end
    end

  end

end

