require 'optparse'
require 'ostruct'

module GemDo

  # GemDo's command-line interface.
  #
  # Also is the namespace for all GemDo command-line subclasses.
  class CLI

    # Add command class to the list of available commands.
    def self.<<(command_class)
      command_classes << command_class
    end

    #
    def self.command_classes
      @command_classes
    end

    #
    def self.run
      #require_commands
      new.run
    end

    #
    #def self.require_commands
    #  cmds = Dir.glob(File.join(File.dirname(__FILE__), 'commands', '*.rb'))
    #  cmds.each{ |lib| require lib }
    #end

    #
    def run
      begin
        run_command
      rescue => err
        raise(err) if $DEBUG
        $stderr.puts err.message
      end
    end

  private

    # Get a list of command classes.
    def commands
      self.class.command_classes
    end

    #
    def run_command
      job = parse_command

      begin
        exec ["gemdo-#{job}", *ARGV]
        #cmd = commands.find{ |c| c.to_s.downcase == job }
      rescue NameError
        puts "Unrecognized command -- #{job}"
        exit 1
      end

      cmd.run
    end

    #
    def parse_command
      job = ARGV.shift

      case job
      when '--help', '-h', nil
        puts(manpage || COMMAND_HELP)
      when 'help'
        name = ARGV.shift
        puts(manpage(name) || COMMAND_HELP)
        exit
      end

      job
    end

    COMMAND_HELP = <<-END.gsub(/^\ {6}/, '')
      gemdo <COMMAND> [OPTIONS ...]

      BUILT-IN COMMANDS:
        about                            show a summary of project
        show [name]                      show specific metadata entry
        news                             show the last release history entry
        bump                             bump version number
        init                             make a starter Ruby project
        help                             show this help message

      COMMON OPTIONS:
        --debug                          activate debug mode

      Use 'gemdo <COMMAND> --help' for command options.
    END

    # TODO:
    #  resolve                          resolve dependencies
    #  gemspec                          make a gemspec file

    def manpage(name=nil)
      name = name ? "gemdo-#{name}" : "gemdo"
      dir = File.dirname(__FILE__) + '/../../man'
      file = File.join(dir, name + '.ronn')
      File.exist?(file) ? File.read(file) : nil
    end

    #
    def require_command(name)
    end

  end#class Command

end
