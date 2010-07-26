require 'pom/project'

module POM
  DIRECTORY = File.dirname(__FILE__)

  def self.metadata
    @metadata ||= %w{version profile gemfile}.inject({}) do |data, name|
      data.merge(YAML.load(File.new(DIRECTORY + "/pom.meta/#{name}.yml")))
      data
    end
  end

  # Access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    name = name.to_s.downcase
    metadata[name]
  end
end

