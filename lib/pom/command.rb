#!/usr/bin/env ruby

require 'pom'
require 'optparse'
require 'ostruct'

module POM

  # POM's command-line interface.
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
        raise(err) if $DEBUG
        $stderr.puts err.message
      end
    end

  private

    #
    def run_command
      job = parse_command
      begin
        #job = 'dotruby' if job == '.ruby'
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
  about                            show a summary of project
  show [name]                      show specific metadata entry
  init                             make a starter Profile file
  spec                             make the .prospec file
  gemspec                          make a gemspec file
  resolve                          resolve dependencies
  news                             show the last release history entry
  bump                             bump version number
  help                             show this help message

COMMON OPTIONS:
  --debug                          activate debug mode

Use 'pom <COMMAND> --help' for command options.
END

  end#class Command

  # Module to house all POM command-line utility classes.
  #
  module Commands

    # Base class for POM commands.
    class Base
      #
      attr :options

      #
      attr :arguments

      #
      def initialize
        @options   = OpenStruct.new
        @arguments = []
      end

      #
      def run
        parse
        execute
      end

      #
      def parse
        parser.parse!
        @arguments = ARGV
      end

      #
      def parser(&block)
        @parser ||= (
          opt = OptionParser.new(&block)

          opt.on("--debug", "run in debug mode") do
            $DEBUG   = true
            $VERBOSE = true
          end

          opt.on_tail("--help", "-h", "display this help message") do
            puts opt
            exit
          end

          opt
        )
      end

      def self.run
        new.run
      end

    end#class Base

  end#module Commands

end#module POM

