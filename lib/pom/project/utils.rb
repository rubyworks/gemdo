require 'facets/string/unfold'

module POM

  class Project

    # Project utility methods.
    module Utils

      # TODO: Get this from project?
      README = "README{,.*}"

      # Project release announcement built on README.
      def announcement(*parts)
        ann = []
        parts.each do |part|
          case part.to_sym
          when :message
            ann << "#{metadata.title} #{self.version} has been released."
          when :description
            ann << "#{metadata.description}"
          when :resources
            list = ''
            metadata.resources.each do |r|
              name = r.label || r.type.to_s.capitialize
              if name
                list << "* #{name}: #{r.uri}\n"
              else
                list << "* #{r.uri}\n"
              end
            end
            ann << list
          when :release
            ann << "= #{title} #{history.release}"
          when :version
            ann << "= #{history.release.header}"
          when :notes
            ann << "#{history.release.notes}"
          when :changes
            ann << "#{history.release.changes}"
          #when :line
          #  ann << ("-" * 4) + "\n"
          when :readme
            release = history.release.to_s
            if file = Dir.glob(README, File::FNM_CASEFOLD).first
              readme  = File.read(file).strip
              readme  = readme.gsub("Please see HISTORY file.", '= ' + release)
              ann << readme
            end
          when String
            ann << part
          when File
            ann << part.read
            part.close
          end
        end
        ann.join("\n\n").unfold
      end

    end

  end

end
