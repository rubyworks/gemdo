module POM

  # This class encapulates algorithms that attempt to infer
  # project metdata from various "common" parts of a project
  # For example, the project's copyright may be infered from
  # a Copyright statement in the project's README file.
  #
  # TODO: This needs to be implement. It will be based on some
  # code in the init.rb command, as well as the import methods
  # in gemspec.rb and readme.rb, as well as the old version helper
  # code in work/.
  class Inference

    # Failing to find a name for the project, the last hope
    # is to discern it from the lib files.
    def infer_name
      if file = root.glob('lib/*.rb').first
        file.basename.to_s.chomp('.rb')
      else
        nil
      end
    end

    #
    def infer_version
      vfile = root + 'VERSION'
      if vfile.exist?
        text = vfile.read

        # ...
      end
    end

  end

end


=begin
    #require 'pom/package/simple_style'
    #require 'pom/package/jeweler_style'
    #require 'pom/package/pom_style'
    #require 'pom/package/jpom_style'

    #STYLES = [SimpleStyle, JewelerStyle, POMStyle, JPOMStyle]

    def read!
      if file
        data  = YAML.load(File.new(file.to_s))
        style = STYLES.find{ |s| s.match?(data) }
        extend(style)
        parse(data)
      else
        extend POMStyle
      end
    
      self.name = fallback_name unless self['name']
    end
=end

