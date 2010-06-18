module POM::Commands

  class Bump

    def self.run
      new.run
    end

    attr :project

    #
    def initialize
      @project = POM::Project.new(:lookup=>true)
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      slot  = nil
      state = nil

      parser = OptionParser.new do |opt|
        opt.banner = "pom bump [OPTIONS | ENTRY]"

        opt.on("--major", "-M", "bump major version number") do
          slot = :major
        end

        opt.on("--minor", "-m", "bump minor version number") do
          slot = :minor
        end

        opt.on("--patch", "-p", "bump patch version number") do
          slot = :patch
        end

        opt.on("--build", "-b", "bump build version number") do
          slot = :build
        end

        opt.on("--state", "-s [TERM]", "specify a new state") do |term|
          state = term
        end

        opt.on("--no-write", "-n", "do not write version change") do
          $DRYRUN = true
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

      parser.parse!

      @slot  = slot
      @state = state
      @entry = ARGV.last
    end

    #
    def execute
      if @entry  or @slot or @state
        new_version = project.package.version

        if @entry
          new_version = VersionNumber.new(@entry)
        end

        if @slot
          new_version = new_version.version.bump(@slot)
        end

        if @state
          new_version = new_version.restate(@state)
        end

        # TODO: Fail if new version is less then old version unless $FORCE

        project.package.version = new_version
        project.package.save! unless $DRYRUN
      end

      puts(project.version) 
    end

    ;; private

=begin
    #
    def bump_major
      project.package.version.bump(:major)
      #project.package.major = project.package.major.succ
      #project.package.minor = 0 if project.package.minor
      #project.package.patch = 0 if project.package.patch
      #project.package.build = nil
    end

    #
    def bump_minor
      project.package.version.bump(:minor)
      #project.package.minor = project.package.minor.succ
      #project.package.patch = 0 if project.package.patch
      #project.package.build = nil
    end

    #
    def bump_patch
      project.package.version.bump(:patch)
      #project.package.patch = project.package.patch.succ
      #project.package.build = nil
    end

    #
    def bump_build
      project.package.version.bump(:build)
      #project.package.build = project.package.build.succ
    end
=end

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
