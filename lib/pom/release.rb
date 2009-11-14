require 'pom/corext'
require 'pom/history'

module POM

  # = Release Notes
  #
  # This class provides the latest release notes for a project.
  # These notes are either extracted from the latest entry in
  # the +HISTORY+ file or taken from a +RELEASE+ file, if
  # provided. The +RELEASE+ file can optionally be called +NEWS+,
  # and have an extension.
  #
  # There are two part to release notes, the +notes+ and the
  # list of +changes+.
  class Release

    DEFAULT_FILE = '{RELEASE,NEWS}{,.*}'

    # Root directory of project.
    attr :root

    # Release file, if any.
    attr :file

    # Release notes.
    attr :notes

    # List of changes.
    attr :changes

    # New Release
    def initialize(root, history=>nil)
      @root    = root
      @history = history

      @notes   = ''
      @changes = ''

      @file = root.glob(DEFAULT_FILE, :casefold).first

      if @file
        read(@file)
      else
        rel = history.releases[0]
        @notes   = rel.notes
        @changes = rel.notes
      end
    end

    # TODO: Improve parsing to RELEASE file.
    def read(file)
      text = File.read(file)
      index = notes.index(/^(##|==)/m)
      if index
        @notes   = notes[0...index]
        @changes = notes[index..-1]
      else
        @notes   = text
      end
    end

    # Access to HISTORY file.
    def history
      @history ||= History.new(root)
    end

  end #class ReleaseNotes

end #module POM

