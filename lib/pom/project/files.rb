module POM

  class Project

    #
    module Files

      # File glob for matching README file.
      README = "README{,.*}"

      # Access to the +Profile+ file.
      def profile
        @profile ||= Profile.new(root)
      end

      # Access to the +README+ file.
      def readme
        @readme ||= Readme.new(root)
      end

    end

  end

end
