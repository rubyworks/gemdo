require 'facets/pathname'

module POM

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
    def initialize(root_directory)
      @file = root_directory.glob_first(DEFAULT_FILE, :casefold)
    end

    # Parses the MANIFEST file and returns it as an array of
    # file names. Blank lines and commented lines (using '#')
    # are ignored.
    def list
      @list ||= (
        files = File.readlines(file).map{ |line| line.strip }
        files.reject{|line| line == '' or line =~ /^[#]/ }
      )
    end

    # Alternate reference to the manifest list.
    alias_method :files, :list

    # Iterate over each file in the manifest.
    def each(&block)
      list.each(&block)
    end

    # Size of the manifest.
    def size ; list.size ; end
  end

end
