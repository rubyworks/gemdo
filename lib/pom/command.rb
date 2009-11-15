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
      cmd = POM::Commands.const_get(job.capitalize)
      cmd.run
    end

    #
    def parse_command
      job = ARGV.shift || 'about'

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
  show <name>                      show specific metadata entry
  init                             create default meta entries
  gemspec                          generate a gemspec
END

  end#class Command

end#module POM

