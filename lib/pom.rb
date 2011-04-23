module POM
  # Where in project to store backups.
  BACKUP_DIRECTORY = '.cache/pom'

  #
  def self.metadata
    @metadata ||= (
      require 'yaml'
      file = File.dirname(__FILE__) + "/pom.yml"
      YAML.load(File.new(file))
    )
  end

  # Access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end
end

require 'pom/project'

