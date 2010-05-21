module POM::Commands
  require 'pom/metadir'
  require 'pom/profile'
  require 'pom/verfile'

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

        opt.on("--force", "overwrite pre-existing PROFILE/VERSION") do
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
      if File.exist?('PROFILE') or File.exist?('VERSION')
        abort "use --force to overwrite PROFILE and VERSION files" unless $FORCE
      end
      metadir = POM::Metadir.new('.')
      if metadir.store
        profile = metadir.to_profile
        verfile = metadir.to_verfile
        profile.save!('PROFILE')
        verfile.save!('VERSION')
      end
    end

  end

end

