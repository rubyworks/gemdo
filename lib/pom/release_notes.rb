require 'facets/pathname'

module POM

  # Release file.
  #
  # DEPRECATE: We will use improved History file instead.
  class ReleaseNotes

    DEFAULT_FILE = '{release,notes,news}{,.txt}'

    attr :file

    attr :notes

    attr :changes

    # New ReleaseNotes.
    def initialize(root_directory)
      @notes   = ''
      @changes = ''

      @file = root_directory.glob(DEFAULT_FILE, :casefold).first

      read
    end

    #
    def read
      if @file
        text = File.read(file)
        index = notes.index(/^(##|==)/m)
        if index
          @notes   = notes[0...index]
          @changes = notes[index..-1]
        else
          @notes   = text
        end
      end
    end

  end #class ReleaseNotes

end #module POM

