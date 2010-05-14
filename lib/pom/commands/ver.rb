module POM::Commands

  class Ver

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
        opt.banner = "pom show [ENTRY]"

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

        opt.on("--state", "-s [TERM]", "specify a state") do |term|
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
      if @slot or @state or @entry
        if @slot
          __send__("bump_#{@slot}")
        elsif @entry
          # TODO: fail is new version is less then old version
          project.version = @entry
        end

        if @state
          project.verfile.state = @state
          project.verfile.build = 1 unless project.verfile.build
        end

        project.verfile.save! unless $DRYRUN
      end
      puts(project.version) 
    end

  private

    #
    def bump_major
      project.verfile.major = project.verfile.major.succ
      project.verfile.minor = 0 if project.verfile.minor
      project.verfile.patch = 0 if project.verfile.patch
      project.verfile.state = nil
      project.verfile.build = nil
    end

    #
    def bump_minor
      project.verfile.minor = project.verfile.minor.succ
      project.verfile.patch = 0 if project.verfile.patch
      project.verfile.state = nil
      project.verfile.build = nil
    end

    #
    def bump_patch
      project.verfile.patch = project.verfile.patch.succ
      project.verfile.state = nil
      project.verfile.build = nil
    end

    #
    def bump_build
      project.verfile.build = project.verfile.build.succ
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
