class POM::Metadata

  def rubyforge
    @data['rubyforge'] ||= Rubyforge.new(self, 'rubyforge')
  end

  #
  class Rubyforge < POM::FileStore

    #
    attr_accessor :unixname

    #
    attr_accessor :groupid

    # D E F A U L T S

    #
    #def initialize_defaults
    #  @data = {}
    #  @data['unixname'] = parent.suite
    #end

    default_value(:unixname){ parent.suite }

    # S P E C I A L  S E T T E R S

    #
    def groupid=(id)
      raise ValidationError unless /\d+/ =~ id
      @data['groupid'] = id
    end

  end

end

