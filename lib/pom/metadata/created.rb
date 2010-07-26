require 'date'

class POM::Metadata

  #
  class Created < Date

    # TODO: More efficeint convervion of Date value?
    def self.new(value)
      case value
      when Date, Time, DateTime
        parse(value.to_s)
      else
        parse(value)
      end
    end

    include AbstractField

    def to_data
      strftime('%Y-%m-%d')
    end

  end

end

