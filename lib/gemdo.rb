module Gemdo
  DIRECTORY = File.dirname(__FILE__)

  def self.metadata
    @metadata ||= %w{PROFILE PACKAGE}.inject({}) do |data, name|
      file = DIRECTORY + "/gemdo.ruby/#{name}"
      data.merge!(YAML.load(File.new(file)))
      data
    end
  end

  # Access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    name = name.to_s.downcase
    metadata[name]
  end
end

require 'gemdo/project'

