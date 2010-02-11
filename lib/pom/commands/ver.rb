module POM::Commands

  class Ver

    def self.run
      new.run
    end

    attr :project

    attr :tuple

    #
    def initialize
      @project = POM::Project.new(:lookup=>true)
      @tuple   = @project.metadata.version.split(/\W/)
    end

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom show [ENTRY]"

        opt.on("--major", "-M", "bump major version number") do
          bump(0)
        end

        opt.on("--minor", "-m", "bump minor version number") do
          bump(1)
        end

        opt.on("--patch", "-p", "bump patch version number") do
          bump(2)
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

      @entry = ARGV.last
    end

    #
    def execute
      puts tuple.join('.')
    end

  private

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

  end

end
