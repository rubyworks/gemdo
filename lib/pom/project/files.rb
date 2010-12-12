module POM

  class Project

    #
    module Files

      # Access to the +.prospec+ file.
      #--
      # TODO: Is this really needed, since we have access to it
      # via profile.metadata?
      #++
      def prospec
        @prospec ||= Metadata.new(root)
      end

      # Access to the +Profile+ file.
      def profile
        @profile ||= Profile.new(root)
      end

      # Access to the general +README+ file
      def readme
        @readme ||= Readme.new(root)
      end

      # TODO: Isn't readme.file good enough?
      def readme_file
        Dir.glob(root + Readme::FILE_PATTERN, File::FNM_CASEFOLD).first
      end

      # Project manifest. For manifest file use <tt>manifest.file</tt>.
      def manifest
        @manifest ||= Manifest.new(root)
      end

      # Access to project history.
      def history
        @history ||= History.new(root)
      end

      # Access latest release notes.
      def news
        @news ||= News.new(root, :history=>history)
      end

      # Returns list of executable files in bin/.
      def executables
        root.glob('bin/*').select{ |bin| bin.executable? }.map{ |bin| File.basename(bin) }
      end

      # List of extension configuration scripts.
      # These are used to compile the extensions.
      def extensions
        root.glob('ext/**/extconf.rb')
      end

      # Returns +true+ if the project have native extensions.
      def compiles?
        !extensions.empty?
      end

    end

  end

end
