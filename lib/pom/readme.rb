require 'pom/corext'

module POM

  # Readme is designed to parse a README file
  # applying various hueristics in order to
  # descern metadata about a project.
  #
  class Readme

    attr :root

    attr :file

    attr :text

    #
    def initialize(root)
      if File.directory?(root)
        @root = root
        @file = root.first('{README,README.*}', :casefold)
        @text = File.read(@file) if @file
      elsif File.file?(root)
        @root = File.dirname(root)
        @file = root
        @text = File.read(@file)
      else
        @text = ''
      end
      @cache = {}
    end

    #
    def [](name)
      return nil unless file
      if respond_to?(name)
        send(name)
      else
        nil
      end
    end

    def description
      if @cache.key?(:description)
        @cache[:description]
      else
        @cache[:description] = description_1
      end
    end

    def license
      if @cache.key?(:license)
        @cache[:license]
      else
        @cache[:license] = license_1
      end
    end

  private

    def description_1
      if md = /[=#]+\s*(DESCRIPTION|ABSTRACT)[:]*(.*?)[=#]+/m.match(text)
        md[2].strip
      end
    end

    #
    def description_2
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

