require 'facets/pathname'

module POM

  class Project #:nodoc:

    # Manifest file.
    #
    class Manifest
      include Enumerable

      DEFAULT_FILE = 'manifest{,.txt}'

      attr :file

      def initialize(root_directory)
        @file = root_directory.glob_first(DEFAULT_FILE, :casefold)
      end

      def list
        @list ||= (
          files = File.readlines(file).map{ |line| line.strip }
          files.reject{|line| line == '' or line =~ /^[#]/ }
        )
      end

      alias_method :files, :list

      def each(&block)
        list.each(&block)
      end

      def size ; list.size ; end
    end

  end

end
