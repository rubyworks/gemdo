require 'gemdo'

module GemDo
module CLI

  # Command to bump version number.
  #
  class Bump < Base

    attr :project

    #
    def initialize
      @project = POM::Project.find
      @slots   = []
      @state   = nil
      @force   = false
    end

    #
    def run
      parse
      execute
    end

    # Returns instance of option parser.
    def parser
      @parser ||= OptionParser.new do |opt|
        opt.banner = "pom bump [OPTIONS | ENTRY]"

        opt.on("--major", "-M", "bump major version number") do
          @slots << :major
        end

        opt.on("--minor", "-m", "bump minor version number") do
          @slots << :minor
        end

        opt.on("--patch", "-p", "bump patch version number") do
          @slots << :patch
        end

        opt.on("--build", "-b", "bump build version number") do
          @slots << :build
        end

        opt.on("--state", "-s", "bump version state") do |term|
          @slots << :state
        end

        opt.on("--no-write", "-n", "do not write version change") do
          $DRYRUN = true
        end

        opt.on("--force", "-f", "force otherwise protected action") do
          @force = true
        end

        opt.on("--debug", "run in debug mode") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end
    end

    #
    def parse
      parser.parse!

      @entry = ARGV.last

      if @entry == 'help'
        puts parser
        exit
      end
    end

    #
    def execute
      if POM::VersionNumber::STATES.include?(@entry)
        @state = @entry.to_sym
      end

      if POM::VersionNumber::SLOTS.include?(@entry)
        @slots << @entry.to_sym
        @entry = nil
      end

      raise "Why bump if you know what you want, silly?" if @entry && !@slots.empty?

      new_version = @entry ? POM::VersionNumber.new(@entry) : project.version

      @slots.each do |slot|
        new_version = new_version.bump(slot)
      end

      if @state
        new_version = new_version.restate(@state)
      end

      if new_version > project.version or @force
        project.version = new_version
        #project.save_version! unless $TRIAL
      else
        if new_version < project.version
          $stderr.puts "pom: Going backwards in time?"
          $stderr.outs "   New version is older than current version."
          #$stderr.outs "   Use --force to fly the TARDIS."
        end
      end

      puts(project.version) 
    end

  end

end
end
