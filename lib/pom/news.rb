require 'pom/core_ext'
require 'pom/history'

module POM

  # = News / Release Notes
  #
  # This class provides access to the latest news / release notes,
  # for a project. These notes are either extracted from a +NEWS+
  # file or from the lastest entry in the +HISTORY+ file.
  #
  class News < History::Release

    # Search glob if any files exist in project from which
    # the Release class can gather information.
    FILE_PATTERN = '{NEWS,RELEASE}{,.*}'

    #
    def self.file_pattern
      FILE_PATTERN
    end

    #
    def self.find(root)
      root = Pathname.new(root)
      root.glob(file_pattern, :casefold).first
    end

    # Root directory of project.
    attr :root

    # Release file, if any.
    attr :file

    # New News ;)
    def initialize(root, opts={})
      @root    = Pathname.new(root)
      @history = opts[:history]

      @file = opts[:file] || self.class.find(root)

      if @file
        @text = File.read(@file)
        super(@text)
      end

      if !file && history
        @text     = history.release.text

        @header   = history.release.header
        @notes    = history.release.notes
        @changes  = history.release.changes

        @version  = history.release.version
        @date     = history.release.date
        @nickname = history.release.nickname
      end
    end

    # NEWS file.
    def file
      @file
    end

    # Lazy access to HISTORY file.
    def history
      return @history unless @history.nil?
      @history = (
        if History.find(root)
          History.new(root)
        else
          false
        end
      )
    end

  end #class News

end #module POM
