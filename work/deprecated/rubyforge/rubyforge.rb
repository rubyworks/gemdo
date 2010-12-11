class POM::Metadata

  def rubyforge
    @data['rubyforge'] ||= Rubyforge.new(self, 'rubyforge')
  end

  #
  class Rubyforge < POM::FileStore

    #
    attr_accessor :unixname, :default => lambda{ parent.suite }

    #
    attr_accessor :groupid

    # S P E C I A L  S E T T E R S

    #
    def groupid=(id)
      raise ValidationError unless /\d+/ =~ id
      self['groupid'] = id
    end

  end

end

