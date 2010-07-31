require 'gemdo/core_ext'
require 'gemdo/version'

module Gemdo

  # = History File
  #
  # The History class parses a HISTORY file into individual
  # release sections. The file is expected to be in RDoc or simple
  # Mardkdown format with each section beginning with a secondary
  # header (== or ##) giving *version* and *date* of release,
  # then a *note* followed by a point by point outline of *changes*.
  #
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
  # +Changes:+ is used as a parsing marker. While optional, it
  # helps the parser find the list of changes, rather than looking
  # for an asterisk or digit, so that ordered and unordered lists
  # can be used in the note section too.
  #
  # TODO: Deal with ChangeLog like formats? Perhaps just make extendable
  # to handle custom formats.
  #
  class History

    # File glob for finding the HISTORY file.
    DEFAULT_FILE = '{History}{,.*}'

    #
    def self.find(root)
      root = Pathname.new(root)
      root.glob(DEFAULT_FILE, :casefold).first
    end

    # HISTORY file's pathname.
    attr :file

    # List of release entries.
    attr :releases

    # New History.
    def initialize(root, opts={})
      @root     = Pathname.new(root)
      @file     = opts[:file] || self.class.find(root)
      read
    end

    # Match against version number string.
    HEADER_RE = /^[=#]+\s*\d+\.\S+/

    # Read and parse the Histoy file.
    def read
      @releases = []
      entry = nil
      if file
        file.readlines.each do |line|
          if HEADER_RE =~ line
            @releases << Release.new(entry) if entry
            entry = line
          else
            next unless entry
            entry << line
          end
        end
        @releases << Release.new(entry)
      end
    end

    # Returns first entry in releases list.
    def release
       releases.first
    end

    # History release entry.
    class Release

      include VersionHelper

      # The full text of the release note.
      attr :text

      # The header.
      attr :header

      # The description.
      attr :notes

      # The list of changes.
      attr :changes

      # Version number (as a string).
      attr :version

      # Release date.
      attr :date

      # Nick name of the release, if any.
      attr :nickname

      #
      def initialize(text)
        @text = text.strip
        parse
      end

      # Returns the complete text.
      def to_s
        text
      end

      ;; private

      # Parse the release text into +header+, +notes+
      # and +changes+ components.
      def parse
        lines = text.lines.to_a

        @header = lines.shift.strip

        parse_release_stamp(@header)

        # remove blank lines from top
        lines.shift until lines.first !~ /^\s+$/

        # find line that looks like the startt of a list of c hanges.
        idx = nil
        idx ||= lines.index{ |line| /^changes\:\s*$/i =~ line }
        idx ||= lines.index{ |line| /^1.\ / =~ line }
        idx ||= lines.index{ |line| /^\*\ / =~ line }

        if idx.nil?
          @notes   = lines.join
          @changes = ''
        elsif idx > 0
          @notes   = lines[0...idx].join
          @changes = lines[idx..-1].join
        else
          gap = lines.index{ |line| /^\s*$/ =~ line }
          @changes = lines[0...gap].join
          @notes   = lines[gap..-1].join
        end
      end

      # Parse out the different components of the header, such
      # as `version`, release `date` and release `nick name`.
      def parse_release_stamp(text)
        # version
        if md = /\b(\d+\.\d.*?)(\s|$)/.match(text)
          @version = md[1]
        end
        # date
        if md = /\b(\d+\-\d+\-.*?\d)(\s|\W|$)/.match(text)
          @date = md[1]
        end
        # nickname
        if md = /\"(.*?)\"/.match(text)
          @nickname = md[1]
        end
      end
    end

  end #class History

end #module Gemdo

