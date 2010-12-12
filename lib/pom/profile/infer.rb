module POM

  class Profile

    # This module encapulates a few algorithms that attempt to infer
    # project metdata from various "common" parts of a project
    # For example, the project's name may be able to be infered from
    # a ruby file in the lib/ directory.
    #
    # Inference is limited to required metadata fields. Using inference
    # to gather additonal information would discourage proper use of POM
    # metadata file.

    module Infer

      # Failing to find a name for the project, the last hope
      # is to discern it from the lib files.
      def infer_name
        if file = root.glob('lib/*.rb').first
          name = file.basename.to_s.chomp('.rb')
          name
        end
      end

      # Extract version from VERSION file.
      #--
      # TODO: It might be better to support the VERSION file as a separate class,
      # in the same way as we support README and MANFIEST.
      #
      # TODO: Support for codename?
      #++
      def infer_version
        vfile = root.glob('VERSION{,.txt,.yml,.yaml}', File::FNM_CASEFOLD)
        if vfile.exist?
          text = vfile.read.strip
          case text
          when /\A---/
            type = :yaml
          when /\A\d+[.]/
            type = :text
          when /[:]/
            type = :yaml
          else
            type = nil
          end

          case type
          when :yaml
            data = YAML.load(text)
            data = data.inject({}){|h,(k,v)| h[k.to_sym]=v; h}
            text = data.values_at(:major,:minor,:patch,:build).compact.join('.')
            text
          when :text
            text
          end
        end
      end

    end

  end

end

