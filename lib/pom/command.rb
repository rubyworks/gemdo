#!/usr/bin/env ruby

require 'pom'
require 'optparse'

module POM

  class Command

    #    
    def self.run
      require_commands
      new.run
    end

    #
    def self.require_commands
      cmds = Dir.glob(File.join(File.dirname(__FILE__), 'commands', '*.rb'))
      cmds.each{ |lib| require lib }
    end

    #
    def initialize
      $TRIAL = nil
      $FORCE = nil
    end

    #
    def run
      begin
        run_command
      rescue => err
        raise err if $DEBUG
        puts err.message
      end
    end

  private

    #
    def run_command
      job = parse_command
      begin
        cmd = POM::Commands.const_get(job.capitalize)
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
      when 'help', '--help', '-h'
        puts COMMAND_HELP
        exit
      end

      job
    end

COMMAND_HELP = <<-END
pom <COMMAND> [OPTIONS ...]

COMMANDS:
  about                            summary of project
  dump                             output all metadata in YAML format
  show [name]                      show specific metadata entry
  init                             create default meta entries
  gemspec                          generate a gemspec file
  ver                              show/bump version
  upgrade                          Upgrade old meta directory to files
  help                             show this help message

COMMON OPTIONS:
  --debug                          activate debug mode

Use 'pom <COMMAND> --help' for command options.
END

  end#class Command

end#module POM

