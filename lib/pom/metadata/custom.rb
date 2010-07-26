require 'delegate'

class POM::Metadata

  #
  class Custom < SimpleDelegator

    #extend AbstractField

    #def self.name
    #  'summary'
    #end

    #def self.store
    #  'yaml:profile.yml'
    #end

    def to_data
      to_s
    end

  end

end

