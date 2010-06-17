module POM

  module VersionHelper

    #
    def parse_release_stamp(text)
      release = {}
      # version
      if md = /\b(\d+\.\d.*?)\s/.match(text)
        release[:version] = md[1]
      end
      # date
      if md = /\b(\d+\-\d.*?)\s/.match(text)
        release[:date] = md[1]
      end
      # codename
      if md = /\"(.*?)\"/.match(text)
        release[:billname] = md[1]
      end
      release
    end

    #
    def parse_release_hash(data)
      data = data.inject({}){ |h,(k,v)| h[k.to_sym] = v; h }
      release = {}
      release[:version]  = data.values_at(:major,:minor,:patch,:build).compact.join('.')
      release[:date]     = data[:date]
      release[:billname] = data[:bill] || data[:billname]
      release
    end

=begin
    #
    def parse_version_file
      file = root.glob('VERSION{,.txt,.yml,.yaml').first
      if file
        text = file.read.strip
        if file.extname == '.yml' or file.extname == '.yaml' or text[0,3] == '---'
          parse_version_yaml(text)
        else
          parse_version_text(text)
        end
      end
    end
=end

  end

end
