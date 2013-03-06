require 'gemdo/project'

module GemDo
  # Where in project to store backups.
  # TODO: Move to Config.
  BACKUP_DIRECTORY = '.cache/gemdo'

  #
  def self.metadata
    @metadata ||= (
      require 'yaml'
      file = File.dirname(__FILE__) + "/gemdo.yml"
      YAML.load(File.new(file))
    )
  end

  # Access to project metadata, e.g. VERSION.
  def self.const_missing(name)
    metadata[name.to_s.downcase] || super(name)
  end
end


