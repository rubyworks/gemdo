require 'gemdo/version'

module Gemdo::Commands

  class Bump

    #
    def self.run
      new.run
    end

    attr :project

    #
    def initialize
      @project = Gemdo::Project.new(:lookup=>true)
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
        opt.banner = "gemdo bump [OPTIONS | ENTRY]"

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
      if Gemdo::VersionNumber::STATES.include?(@entry)
        @state = @entry.to_sym
      end

      if Gemdo::VersionNumber::SLOTS.include?(@entry)
        @slots << @entry.to_sym
        @entry = nil
      end

      raise "Why bump if you know what you want, silly?" if @entry && !@slots.empty?

      new_version = @entry ? Gemdo::VersionNumber.new(@entry) : project.package.version

      @slots.each do |slot|
        new_version = new_version.bump(slot)
      end

      if @state
        new_version = new_version.restate(@state)
      end

      if new_version > project.package.version or @force
        project.package.version = new_version
        project.package.save_version! unless $TRIAL
      else
        if new_version < project.package.version
          $stderr.puts "gemdo: Going backwards in time?"
          $stderr.outs "   New version is older than current version."
          $stderr.outs "   Use --force to fly the TARDIS."
        end
      end

      puts(project.version) 
    end

=begin
    # Bump given version index.
    def bump(index)
      tuple[index] = bump_entry(tuple[index])
      (index+1...tuple.size).each do |i|
        tuple[i] = null_entry(tuple[i])
      end
    end

    #
    def bump_entry(entry)
      case entry
      when /^\d+$/
        entry.to_i.succ.to_s
      when /^(\D)*(\d)(\D)*$/
        $1 + $2.to_i.succ.to_s + $3
      when nil
        "1"
      else
        entry
      end
    end

    #
    def null_entry(entry)
      case entry
      when /^\d+$/
        "0"
      when /^(\D)*(\d)(\D)*$/
        $1 + "0" + $3
      when nil
        "0"
      else
        entry
      end
    end
=end

  end

end
