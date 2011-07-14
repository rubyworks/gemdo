module POM

  #
  def self.property(name, &block)
    Property.new(name, &block)
  end

  # Property class defines a metadata field.
  class Property

    # Dummy object.
    NA = Object.new

    #
    def self.list
      @list ||= []
    end

    #
    def self.find(name)
      list.find{ |property| property.names.include?(name.to_sym) }
    end

    def initialize(name, &block)
      @name = name.to_sym

      Property.list << self

      @aliases   = []
      @parser    = nil

      instance_eval(&block) if block
    end

    #
    def name
      @name
    end

    #
    def aliases(*list)
      if list.empty?
        @aliases
      else
        @aliases = list.map{ |a| a.to_sym }
      end
    end

    #
    def names
      [name, *aliases]
    end

    #
    def parse(value=NA, &block)
      if value == NA
        @parser = block
      else
        @parser.call(value)
      end
    end

    #
    def parser 
      @parser
    end

    #
    def default(value=NA, &block)
      if block
        @default = block
      else
        @default = value if value != NA
      end
      @default
    end

    #
    def validate(value=NA, &block)
      if value == NA
        @validate = block
      else
        @validate.call(value)
      end
    end

  end

end

