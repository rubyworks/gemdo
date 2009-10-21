require 'pom/corext'

module POM

  # = History File
  #
  # The History class parses a HISTORY file into individual
  # release sections. The file is expected to be in RDoc format
  # with each section beginning with a secondary header (==)
  # giving *version* and *date* of release, then a *note*
  # followed by a point by point outline of *changes*.
  # For example:
  #
  #   == 1.0.0 / 2009-10-07
  #
  #   Say something about this version.
  # 
  #   Changes:
  #
  #   * outline oimportant changelog items
  #
  # +Changes:+ is used a parsing marker, rather than looking
  # for an '*', so that lists can be used in the release note
  # too.
  #
  # TODO: Allow the format to be more varied.
  #
  class History

    # File glob for finding the HISTORY file.
    DEFAULT_FILE = '{History}{,.*}'

    # HISTORY file's pathname.
    attr :file

    # List of release entries.
    attr :releases

    # New History.
    def initialize(root)
      @root = Pathname.new(root)
      @file = @root.first(DEFAULT_FILE, :casefold)
      @releases = []
      read
    end

    # Read and parse the Histoy file.
    def read
      if file
        text = file.read.strip
        text = text.sub(/\A[=]\s+(.*?)$/,'').strip
        scan = text.scan(/\=\=(.*?)\n(.*?)(^Changes:.*?)(?=\=\=|\Z)/m)
        scan.each do |header, notes, changes|
          @releases << Release.new(header, notes, changes)
        end
      end
    end

    # Returns first entry in releases list.
    def release
       releases.first
    end

    # History Release Entry
    class Release
      attr :header
      attr :notes
      attr :changes
      def initialize(header, notes, changes)
        @header  = header.strip
        @notes   = notes.strip
        @changes = changes.strip
      end
      def to_s
        "== #{header}\n\n#{notes}\n\n#{changes}"
      end
    end

  end #class History

end #module POM
