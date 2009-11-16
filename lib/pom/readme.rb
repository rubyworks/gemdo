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
    def self.load(path)
      path = Pathname.new(path)
      if path.directory?
        path = path.first('{README,README.*}', :casefold)
      end
      new(path.read)
    end

    #
    def initialize(text)
      @text  = text
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

    #
    def name
      title.downcase
    end

    alias_method :project, :name

    #
    def title
      if @cache.key?(:title)
        @cache[:title]
      else
        @cache[:title] = title_1
      end
    end

    #
    def description
      if @cache.key?(:description)
        @cache[:description]
      else
        @cache[:description] = description_1
      end
    end

    #
    def license
      if @cache.key?(:license)
        @cache[:license]
      else
        @cache[:license] = license_1
      end
    end

  private

    #
    def title_1
      if md = /^[=#]\s*(.*?)$/m.match(text)
        md[1].strip
      end
    end

    #
    def description_1
      if md = /[=#]+\s*(DESCRIPTION|ABSTRACT)[:]*(.*?)[=#]+/m.match(text)
        md[2].strip #.sub("\n", ' ')  # unfold instead of sub?
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

  class Metadata

    # Get POM metadata from a README. This is intended to make it
    # fairly easy to build a set of POM meta/ files if you already have
    # a README.
    #--
    # TODO: Perhaps this should be in Metadata, and then we can if we want
    # have this method too, but calling on it?
    #++
    def self.from_readme(readme, root=Dir.pwd)
      metadata = Metadata.load(root)
      readme   = Readme.new(readme)

      metadata.name        = readme.name
      metadata.title       = readme.title
      metadata.description = readme.description
      metadata.license     = readme.license

      metadata
    end

  end

end

