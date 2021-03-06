require 'pom/core_ext'

module POM

  # Readme is designed to parse a README file
  # applying various hueristics in order to
  # descern metadata about a project.
  #
  class Readme

    # File glob for matching README file.
    FILE_PATTERN = "README{,.*}"

    #
    attr :root

    #
    attr :file

    #
    attr :text

    #
    def self.load(path)
      path = Pathname.new(path)
      if path.directory?
        path = path.first(FILE_PATTERN, :casefold)
      end
      if path
        new(path.read, path)
      else
        new("")
      end
    end

    #
    def initialize(text, file=nil)
      @text  = text
      @file  = file
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
    #alias_method :project, :name

    #
    def title
      @cache[:title]
    end

    #
    def description
      @cache[:description]
    end

    #
    def license
      @cache[:license]
    end

    #
    def copyright
      @cache[:copyright]
    end

    #
    def authors
      @cache[:authors]
    end

    #
    def resources
      @cache[:resources] ||= {}
    end

    #
    def homepage
      resources[:home]
    end

    #
    def wiki
      resources[:wiki]
    end

    #
    def issues
      resources[:issues]
    end

    # Return file extension of README. Even if the file has no extension,
    # this method will look at the contents and try to determine it.
    #--
    # TODO: improve type heuristics
    #++
    def extname
      ext = File.extname(file)
      if ext.empty?
        ext = '.rdoc' if /^\=/ =~ text
        ext = '.md'   if /^\#/ =~ text
      end
      return ext
    end

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
      md = /Copyright.*?\d+(.*?)$/.match(text)
      if md
        @cache[:copyright] = md[0]
        @cache[:authors]   = md[1].split(/(and|\&|\,)/).map{|a|a.strip}
      end
    end

    #
    def parse_resources
      @cache[:resources] = {}

      scan_for_github

      text.scan(/(\w+)\:\s*(http:.*?[\w\/])$/) do |m|
        @cache[:resources][$1] = $2
      end
    end

    #
    # TODO: Improve on github matching.
    def scan_for_github
      text.scan(/http\:.*?github\.com.*?[">\s]/) do |m|
        case m
        when /wiki/
          @cache[:resources]['wiki'] = m[0...-1]
        when /issues/
          @cache[:resources]['issues'] = m[0...-1]
        else
          if m[0] =~ /:\/\/github/
            @cache[:resources]['code'] = m[0...-1]
          else
            @cache[:resources]['home'] = m[0...-1]
          end
        end
      end
    end

    # TODO
    def scan_for_googlegroups
      
    end

    # TODO: parse readme into sections of [label, text].
    #def sections
    #  @sections ||= (
    #    secs = text.split(/^(==|##)/)
    #    secs.map do |sec|
    #      i = sec.index("\n")
    #      n = sec[0..i].sub(/^[=#]*/, '')
    #      t = sec[i+1..-1]
    #      [n, t]
    #    end
    #  )
    #end
  end

  class Project

   #
    def readme
      @readme ||= Readme.load(root)
    end

    # Get POM metadata from a README. This is intended to make it
    # fairly easy to build a set of POM's metadata files if you
    # already have a README.
    def import_readme(readme=nil)
      readme = readme || self.readme

      profile.name        = readme.name         if readme.name

      profile.title       = readme.title        if readme.title
      profile.description = readme.description  if readme.description
      profile.license     = readme.license      if readme.license
      profile.copyright   = readme.copyright    if readme.copyright
      profile.authors     = readme.authors      if readme.authors

      profile.resources.homepage = readme.homepage  if readme.homepage
      profile.resources.wiki     = readme.wiki      if readme.wiki
      profile.resources.issues   = readme.issues    if readme.issues
    end

  end

end

