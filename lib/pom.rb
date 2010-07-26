require 'pom/project'

module POM
  DIRECTORY = File.dirname(__FILE__)

  def self.package
    @pack ||= YAML.load(File.new(File.join(DIRECTORY,'pom/Version.yml')))
  end

  def self.profile
    @file ||= YAML.load(File.new(File.join(DIRECTORY,'pom/Profile.yml')))
  end

  def self.dependencies
    @gems ||= YAML.load(File.new(File.join(DIRECTORY,'pom/Gemfile.yml')))
  end

  # Raw access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    name = name.to_s.downcase
    pkgfile[name] || profile[name]
  end
end

