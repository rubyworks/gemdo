require 'rock/core_ext'

module Rock

  # Manifest file.
  #
  class Manifest
    include Enumerable

    # File glob use for locating the MANIFEST file.
    DEFAULT_FILE = 'manifest{,.txt}'

    # Stores the path of the amnifest file.
    attr :file

    # Instantiate a new Manifest object, provided
    # the root directory of the project.
    def initialize(root)
      @root = root
      @file = root.glob(DEFAULT_FILE, :casefold).first
    end

    # Parses the MANIFEST file and returns it as an array of
    # file names. Blank lines and commented lines (using '#')
    # are ignored.
    def list
      @list ||= (
        if exist?
          files = File.readlines(file).map{ |line| line.strip }
          files.reject{|line| line == '' or line =~ /^[#]/ }
        else
          []
        end
      )
    end

    # Alternate reference to the manifest list.
    alias_method :files, :list

    # Iterate over each file in the manifest.
    def each(&block)
      list.each(&block)
    end

    def exist?
      file
    end

    #
    def empty?
      list.empty?
    end

    # Size of the manifest.
    def size ; list.size ; end
  end

end
