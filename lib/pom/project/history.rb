require 'facets/pathname'

module POM

  class Project #:nodoc:

    # History File
    #
    class History

      DEFAULT_FILE = '{History}{,.*}'

      attr :file

      attr :releases

      # New History.
      def initialize(root)
        @root = Pathname.new(root)
        @file = @root.glob(DEFAULT_FILE, :casefold).first
        @releases = []
        read
      end

      # Read and parse the Histoy file.
      def read
        if @file
          text = File.read(file).strip
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

    end

  end #class Project

end #module POM
