module POM

  # Where in project to store backups.
  BACKUP_DIRECTORY = '.cache/pom'

  #
  def self.metadata
    @metadata ||= (
      file = File.dirname(__FILE__) + "/pom.yml"
      YAML.load(File.new(file))
    )
  end

  # Access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    name = name.to_s.downcase
    metadata[name]
  end

end

require 'pom/project'

