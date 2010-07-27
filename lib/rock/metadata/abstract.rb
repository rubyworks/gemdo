class Rock::Metadata

  #
  module AbstractField

    def self.included(base)
      base.extend Meta
      Rock::Metadata.register(base)
    end

    module Meta
      def name
        super.split('::').last.downcase
      end

      def aliases
        []
      end

      def names
        [name, *aliases]
      end

      def store
        'profile.yml'
      end
    end

    def to_data
      to_s
    end

  end

end

