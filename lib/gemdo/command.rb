#!/usr/bin/env ruby

require 'gemdo'
require 'optparse'
require 'ostruct'

module Gemdo

  # Gemdo's command-line interface.
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
        $stderr.puts err.message
      end
    end

  private

    #
    def run_command
      job = parse_command
      begin
        #job = 'dotruby' if job == '.ruby'
        cmd = Gemdo::Commands.const_get(job.capitalize)
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
gemdo <COMMAND> [OPTIONS ...]

COMMANDS:
  about                            show a summary of project
  show [name]                      show specific metadata entry
  init                             make starter metadata files
  gemspec                          make a gemspec file
  bump                             bump version number
  dump                             show all metadata in YAML format
  help                             show this help message

COMMON OPTIONS:
  --debug                          activate debug mode

Use 'gemdo <COMMAND> --help' for command options.
END

  end#class Command

  # Module to house all Gemdo command-line utility classes.
  #
  module Commands

    # Base class for Gemdo commands.
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

end#module Gemdo

