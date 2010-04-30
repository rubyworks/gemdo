require 'pom/core_ext'

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
      parse
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
    def name ; @cache[:name] ; end

    # DEPRECATE
    alias_method :project, :name

    #
    def title ; @cache[:title] ; end

    #
    def description ; @cache[:description] ; end

    #
    def license ; @cache[:license] ; end

    #
    def copyright ; @cache[:copyright] ; end

    #
    def authors ; @cache[:authors] ; end

    #
    def homepage ; @cache[:homepage] ; end

    #
    def wiki ; @cache[:wiki] ; end

    #
    def issues ; @cache[:issues] ; end

  private

    #
    def parse
      parse_title
      parse_description
      parse_license
      parse_copyright
      parse_resources
    end

    #
    def parse_title
      if md = /^[=#]\s*(.*?)$/m.match(text)
        title = md[1].strip
        @cache[:title] = title
        @cache[:name]  = title.downcase.gsub(/\s+/, '_')
      end
    end

    #
    def parse_description
      if md = /[=#]+\s*(DESCRIPTION|ABSTRACT)[:]*(.*?)[=#]+/m.match(text)
        @cache[:description] = md[2].strip #.sub("\n", ' ')  # unfold instead of sub?
      else
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
        @cache[:description] = d.join(' ').strip
      end
    end

    #
    def parse_license
      if md = /[=]+\s*(LICENSE)/i.match(text)
        section = md.post_match
        @cache[:license] = (
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
        )
      end
    end

    #
    def parse_copyright
      md = /Copyright.*?\d(.*?)$/.match(text)
      if md
        @cache[:copyright] = md[0]
        @cache[:authors]   = md[1].split(/(and|\&|\,)/).map{|a|a.strip}
      end
    end

    #
    def parse_resources
      scan_for_github
    end

    # TODO: Imporve URL Regexp matching.
    def scan_for_github
      text.scan(/http:.*?github\.com.*?[">\s]/) do |m|
        case m
        when /wiki/
          @cache[:wiki] = m[0...-1]
        when /issues/
          @cache[:issues] = m[0...-1]
        else
          @cache[:homepage] = m[0...-1]
        end
      end
    end

    # TODO
    def scan_for_googlegroups
      
    end

  public

    #
    def to_metadata(root=nil)
      metadata = Metadata.new(root)
      metadata.load! if root  # TODO: is there really any reason for the meta/ entries not to take precedence?

      metadata.name        = self.name
      metadata.title       = self.title
      metadata.description = self.description
      metadata.license     = self.license
      metadata.copyright   = self.copyright
      metadata.authors     = self.authors
      metadata.homepage    = self.homepage
      metadata.wiki        = self.wiki
      metadata.issues      = self.issues

      metadata
    end

  end

  class Metadata

    # Get POM metadata from a README. This is intended to make it
    # fairly easy to build a set of POM meta/ files if you already have
    # a README.
    #
    # TODO: Use ReadMe#to_metadata
    #
    def self.from_readme(readme, root=Dir.pwd)
      metadata = Metadata.load(root)
      readme   = Readme.new(readme)

      metadata.name        = readme.name
      metadata.title       = readme.title
      metadata.description = readme.description
      metadata.license     = readme.license
      metadata.copyright   = readme.copyright
      metadata.authors     = readme.authors
      metadata.homepage    = readme.homepage
      metadata.wiki        = readme.wiki
      metadata.issues      = readme.issues

      metadata
    end

  end

end

