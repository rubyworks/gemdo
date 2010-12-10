require 'rubygems'
require 'open-uri'
#require 'json'
require 'yaml'

#gems = Marshal.load(Gem.inflate(open("http://rubygems.org/Marshal.4.8.Z").read))
require 'gemdo'

project = Gemdo::Project.new(Dir.pwd)

list = []

p project.requires

project.requires.each do |req|
  dir  = File.expand_path('~/.gem/specs/rubygems.org%80/quick/Marshal.4.8/')
  libs = Dir[File.join(dir, "#{req.name}-*")]

p libs
end

p list

#puts gems.size

#File.open('GEMS.yml', 'w'){ |f| f << gems.to_yaml }

