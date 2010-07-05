require 'time'
require 'pom/verfile'
require 'pom/version_number'

module POM

  # Current release information.
  class Release

    #
    def initialize(root)
      @root = root
      @done = false
      load_version
    end

    # Project's root pathname.
    attr :root

    #
    attr :version

    # Load date if information if not already loaded
    # and return the current release date.
    #
    # Returns a Time object.
    def date
      load_information
      @date
    end

    #
    def buildno
      load_information
      @buildno
    end

    #
    def codename
      load_information
      @codename
    end

    # Load the current version number. If a VERSION file exists the
    # version number will be taken from it. Otherwise the version
    # number will be looked for in `.meta/verison`.
    def load_version
      #
      if file = Verfile.find(root)
        verfile  = Verfile.new(root, :file=>file)
        @version  = verfile.version
        @date     = verfile.date     if verfile.date
        @codename = verfile.codename if verfile.codename
        @buildno  = verfile.buildno  if verfile.buildno
      elsif vers = meta('version')
        @version = VersionNumber.new(vers)
      else  
        raise "no version"
      end
    end

    # Load additional release information.
    def load_information
      return if @done

      @date ||= (
        if date = meta('date')
          Time.parse(date)
        #else
        #  @date ||= Time.now #?
        end
      )

      @buildno  ||= meta('buildno')
      @codename ||= meta('codename')

      @done = true
    end

  private

    #
    def meta(name)
      if file = meta_file(name)
        File.read(file).strip
      else
        nil
      end
    end

    #
    def meta_file(name)
      root.glob("{,.}meta/#{name}").first
    end

  end

end
