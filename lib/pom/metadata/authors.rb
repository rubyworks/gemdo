class POM::Metadata

  class Authors < Array

    include AbstractField

    #
    def initialize(list)
      replace([list].flatten)
    end

  end

end

