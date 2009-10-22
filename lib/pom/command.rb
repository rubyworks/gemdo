#!/usr/bin/env ruby

require 'pom'
require 'optparse'

options = {}

optparse = OptionParser.new do |opt|

  opt.banner = ""

  opt.on("--noharm", "-n", "don't actually write anything to disk") do
    options[:noharm] = true
  end

  opt.on("--verbose", "-v", "give extra verbose output") do
    options[:verbose] = true
  end

  opt.on("--dryrun", "both --noharm and --verbose") do
    options[:noharm] = true
    options[:verbose] = true
  end

  opt.on("--debug", "run with $DEBUG set to true") do
    $DEBUG = true
  end

  opt.on("--trace", "same as --verbose and --debug") do
    $DEBUG = true
    options[:verbose] = true
  end

  opt.on_tail("--help", "-h", "disaply this help message") do
    puts opt
    exit
  end

end

optparse.parse!

if ARGV.empty?

  require 'rubygems'

  text = STDIN.read.strip

  if /^---/ =~ text
    obj = YAML.load(text)
  else
    obj = text
  end

  case obj
  when Gem::Specification
    project = POM::Project.from_gemspec(obj)
    project.metadata.save
  else
    project = POM::Project.from_readme(obj)
    project.metadata.save
  end

else

  project = POM::Project.new

  case ARGV.first
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

