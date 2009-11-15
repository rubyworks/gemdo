#!/usr/bin/env ruby

require 'pom'
require 'pom/readme'
require 'pom/gemspec'
require 'optparse'

module POM

  class Command

    def self.run ; new.run ; end

    def initialize
      $TRIAL = nil
      @force = nil
    end

    def trial? ; $TRIAL ; end

    def debug? ; $DEBUG ; end

    def force? ; @force ; end

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
      parse

      job = ARGV.pop

      case job
      when 'init'
        init_metadata
        exit
      end

      project = POM::Project.new

      case job
      when 'about'
        project.metadata.load
        puts project.about
      when 'show'
        project.metadata.load
        puts project.metadata.send(ARGV.last)
      when 'dump'
        project.metadata.load
        puts project.metadata.to_yaml
      when 'gemspec'
        File.open(project.metadata.name + '.gemspec', 'w') do |f|
          f << project.to_gemspec.to_yaml
        end
      else
        puts "unknown command -- #{ARGV.first}"
      end

    end

    COMMAND_HELP = <<-HERE
    about                            summary of project
    show [name]                      show specific metadata entry      
    dump                             output all metadata in YAML format
    gemspec                          generate a gemspec
    HERE

    #
    def parse
      optparse = OptionParser.new do |opt|
        opt.banner = "pom <COMMAND> [OPTIONS] [ARGS ...]\n\nCOMMANDS:\n" + COMMAND_HELP + "\nOPTIONS:\n"

        opt.on("--force", "-f", "override safe-guarded operations") do
          @force = true
        end

        #opt.on("--verbose", "-v", "give extra verbose output") do
        #  @verbose = true
        #end

        opt.on("--trial", "run in trial mode, skips disk writes") do
          $TRIAL = true
        end

        opt.on("--debug", "run in debug mode, raises exceptions") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      optparse.parse!
    end

    #
    def init_metadata
      #require 'rubygems'

      exists = Dir.glob('{.,}meta').first

      if exists && !force?
        $stderr << "A #{exists} directory already exists. Use --force option to allow overwrites.\n"
        return
      end

      files = ARGV

      if files.empty?
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      metadata = POM::Metadata.new
      metadata.load_defaults

      files.each do |file|
        text = File.read(file)
        obj  = /^---/.match(text) ? YAML.load(text) : text
        case obj
        when ::Gem::Specification
          metadata.mesh( POM::Metadata.from_gemspec(obj) )
        when String
          metadata.mesh( POM::Metadata.from_readme(obj) )
        when Hash
          metadata.mesh( obj )
        else
          puts "Skipping #{obj.class} cannot be converted into Metadata."
        end
      end

      metadata.load

      metadata.backup! unless trial?

      metadata.save! unless trial?
    end

  end#class Command

end#module POM

