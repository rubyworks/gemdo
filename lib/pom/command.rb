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

    #
    def parse
      optparse = OptionParser.new do |opt|
        opt.banner = "pom [OPTIONS] <COMMAND> [FILE1 FILE2 ...]"

        opt.on("--force", "-f", "override safe-guarded operations") do
          @force = true
        end

        #opt.on("--verbose", "-v", "give extra verbose output") do
        #  @verbose = true
        #end

        opt.on("--trial", "trial mode nulls writes to disk") do
          $TRIAL = true
        end

        opt.on("--debug", "run in debug mode") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "dispaly this help message") do
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
        puts "#{exists} directory already exists; use --force option to allow overwrites"
        return
      end

      files = ARGV

      if files.empty?
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      metadata = POM::Metadata.load
      metadata.backup! unless trial?

      if files.empty?
        metadata.save unless trial?
        #init_metadata_from_nothing
      else
        files.each do |file|
          text = File.read(file)
          obj  = /^---/.match(text) ? YAML.load(text) : text
          case obj
          when ::Gem::Specification
            init_metadata_from_gemspec(obj)
          when String
            init_metadata_from_readme(obj)
          else
            puts "Source type #{obj.class} cannot be converted into Metadata."
          end
        end
      end

    end

    #
    #def init_metadata_from_nothing
    #  metadata.save unless trial?
    #end

    #
    def init_metadata_from_gemspec(spec)
      metadata = POM::Metadata.from_gemspec(spec)
      metadata.save unless trial?
    end

    #
    def init_metadata_from_readme(text)
      metadata = POM::Metadata.from_readme(text)
      metadata.save unless trial?
    end

    #
    def backup(metadata)
      @backup ||= metadata.backup!
    end

  end#class Command

end#module POM

