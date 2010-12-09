module POM

  # The `.ruby` file.
  class DotRuby

    #
    def initialize(root, data={})
      @root = root

      preinitialize_defaults

      data.each do |k,v|
        __send__("#{k}=", v)
      end

      load
    end

    #
    def root
      @root
    end

    #
    def preinitialize_defaults
    end

    #
    def file
      @file ||= ::File.join(root, '.ruby')
    end

    #
    def load
      if File.exist?(file)
        data = YAML.load(::File.new(file))
        data.each do |k,v|
          __send__("#{k}=", v)
        end
      end
    end

    # Load name of project.
    #def name
    #  @name
    #end

    #
    #def name=(name)
    #  raise "invalid name" unless /^\w+$/ =~ name
    #  @name = name
    #end

    # The loadpaths used by the project.
    #def loadpath
    #  @loadpath
    #end

    #
    #def loadpath=(paths)
    #  case paths
    #  when NilClass
    #    @loadpath = ['lib']
    #  when String
    #    @loadpath = paths.split(/[,:;\ ]/)
    #  else
    #    @loadpath = [paths].flatten
    #  end
    #end

    #
    #def module=(mod)
    #  @namespace = mod
    #end

    #
    #def metadata
    #  @metadata ||= default_metadata
    #end

    #
    #def metadata=(sources)
    #  @metadata = [sources].flatten
    #end

    # D E F A U L T S

    # Profile is the collecton of data that provides ancillary information
    # about a project, such as description and authors list.
    #
    # Package is the collection of date that identifies that version and
    # release date.
    #
    # We're using "gem" in a generic sense as meaning a "Ruby Package"
    # regardless of how it was actually installed.
    #def default_metadata
    #  Dir[File.join(meta_dir, "*")]
    #end

    #
    #def reference(path_index)
    #  if md = /\#(.*?)$/.match(path_index)
    #    index      = md[1]
    #    path_index = md.pre_match
    #  end
    #   
    #  if md = /^(.*?)\:\/\//.match(path_index)
    #    protocol   = md[1]
    #    path_index = md.post_match
    #  end
    #
    #  protocol = 'yaml' unless protocol
    #
    #  return path_index, protocol, index
    #end

  end

end

