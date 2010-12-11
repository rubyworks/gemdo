
    # Save package information as Ruby source code.
    #
    #   module Foo
    #     VERSION  = "1.0.0"
    #     RELEASED = "2010-10-01"
    #     CODENAME = "Fussy Foo"
    #   end
    #
    # NOTE: This is not actually needed, as I exmplain in a recent
    # blog post. But we will leave it here for the time being.
    #
    # TODO: Improve upon this, allow selectable fields.
    def save_as_ruby(file)
      if File.exist?(file)
        text = File.read(file)
        save_as_ruby_sub!(text, :version, 'VERSION')
        save_as_ruby_sub!(text, :released, 'RELEASED', 'DATE')
        save_as_ruby_sub!(text, :codename, 'CODENAME')
      else
        t = []
        t << %[module #{codename}]
        t << %[  VERSION  = "#{version}"]
        t << %[  RELEASE  = "#{release}"]
        t << %[  CODENAME = "#{codename}"]
        t << %[end]
        text = t.join("\n")
      end
      File.open(file, 'w'){ |f| f << text }
    end

    #
    def save_as_ruby_sub!(text, field, *patterns)
      patterns = patterns.join('|')
      text.sub!(/(#{patterns}\s*)=\s*(.*?)(?!\s*\#?|$)/, '\1=' + __send__(field))
    end

    #
    def yaml
      s = []
      s << "name    : #{name}"
      s << "date    : #{date.strftime('%Y-%m-%d')}"
      s << "version : #{version}"
      s << "codename: #{codename}" if codename
      s << "loadpath: #{loadpath}" if loadpath
      s << ""
      s << yaml_list('requires' , requires)
      s << yaml_list('replaces' , replaces)
      s << yaml_list('conflicts', conflicts)
      s.compact.join("\n")
    end

    #
    def yaml_list(name, list)
      return nil if list.empty?
      s = "\n#{name}:"
      list.each do |x|
        s << "\n- " + x.yaml.tabto(2)
      end
      s + "\n"
    end

    # This method is not using #to_yaml in order to ensure
    # the file is saved neatly. This may require tweaking.
    def save!(file=nil)
      file = file || @file || self.class.default_filename
      file = @root + file if String === file
      now!  # update date
      File.open(file, 'w'){ |f| f << yaml }
    end


