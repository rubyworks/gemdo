require 'pom/core_ext'
require 'pom/history'
require 'pom/version_helper'

module POM

  # = News / Release Notes
  #
  # This class provides the latest release notes for a project.
  # These notes are either extracted from the latest entry in
  # the +HISTORY+ file or taken from a +RELEASE+ file, if
  # provided. The +RELEASE+ file can optionally be called +NEWS+,
  # and have an extension.
  #
  # TODO: Make resuable by History for release entries.
  class News

    include VersionHelper

    # Search glob if any files exist in project from which
    # the Release class can gather information.
    FILE_PATTERN = '{NEWS,RELEASE}{,.*}'

    #
    def self.file_pattern
      FILE_PATTERN
    end

    #
    def self.find(root)
      root.glob(file_pattern, :casefold).first
    end

    # Root directory of project.
    attr :root

    # Release file, if any.
    #attr :file

    # Release notes.
    attr :notes

    # List of changes.
    attr :changes

    # Version number.
    attr :version

    # Release date.
    attr :date

    # Billing name of release, e.g. "Hardy Haron"
    attr :billname

    # New News.
    def initialize(root, opts={})
      @root    = root
      @history = opts[:history]

      @notes   = ''
      @changes = ''

      @file = root.glob(FIND, :casefold).first

      if @file
        parse
      #else
      #  rel = history.releases[0]
      #  @notes   = rel.notes
      #  @changes = rel.changes
      end
    end

    #
    def file
      @file
    end

    # Access to HISTORY file.
    def history
      @history ||= History.new(root)
    end

    private

    #
    def parse
      text = File.read(file).strip
      line = text.lines.find{ |line| line =~ /\d/ }
      if line
        rel = parse_release_stamp(line)
        @version  = rel[:version]
        @date     = rel[:date]
        @billname = rel[:billname]
      end
      parse_body(text)
    end

    # TODO: Continue to improve parsing of news file.
    # Also, share code with History entries.
    def parse_body(text)
      word = text.index(/^[A-Za-z]/)
      list = text.index(/^(\*|\d+\.)/)

      if list == nil
        @notes = text
      elsif word == nil
        @changes = text.strip
      elsif list > word
        @notes   = notes[0...list].strip
        @changes = notes[list..-1]
      else
        @notes   = notes[word..-1]
        @changes = notes[0...word].strip
      end
    end

  end #class News

end #module POM
