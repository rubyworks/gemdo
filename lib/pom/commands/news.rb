module POM::Commands

  # New command displays the current release notes.
  class News < Base

    attr :project

    #
    def initialize
      super
      @project = POM::Project.new(:lookup=>true)
    end

    #
    def parser
      super do |opt|
        opt.banner = "pom news"

        opt.on("--text", "-t", "show verbatim text") do
          options.text = true
        end

        opt.on("--header", "-h", "include header") do
          options.header = true
        end

        opt.on("--changes", "-c", "include list of changes") do
          options.changes = true
        end
      end
    end

    #
    def execute
      if options.text
        puts project.news.text
      else
        if options.header
          puts project.news.header
          puts
        end
        puts project.news.notes.rstrip
        if options.changes
          puts
          puts project.news.changes
        end
      end
    end

  end

end

