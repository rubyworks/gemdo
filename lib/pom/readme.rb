module POM

  # Readme is designed to parse a README file
  # applying various hueristics in order to 
  # descern metadata about a project.
  #
  class Readme
    attr :text

    def self.load(file)
      new(File.read(file))
    end

    def initialize(text)
      @text = text
    end

    #
    def [](name)
      if respond_to?(name)
        send(name)
      else
        nil
      end
    end

    def description
      @description ||= description_1
    end

    def license
      @license ||= license_1
    end

  private

    #
    def description_1
      d = []
      o = false
      text.split("\n").each do |line|
        if o
          if /^(\w|\s*$)/ !~ line
            break d
          else
            d << line
          end
        else
          if /^\w/ =~ line
            d << line
            o = true
          end
        end
      end
      return d.join(' ').strip
      #if md = /[=]+\s*(DESCRIPTION|ABSTRACT)/.match(text)
      #end
    end

    #
    def license_1
      if md = /[=]+\s*(LICENSE)/i.match(text)
        section = md.post_match
        case section
        when /LGPL/
          "LGPL"
        when /GPL/
          "GPL"
        when /MIT/
          "MIT"
        when /BSD/
          "BSD"
        end
      end
    end

  end

end
