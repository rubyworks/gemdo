module POM

  class Profile

    # This module encapulates a few algorithms that attempt to infer
    # project metdata from various "common" parts of a project
    # For example, the project's name may be able to be infered from
    # a ruby file in the lib/ directory.
    #
    class Inference

      #
      def self.inference_methods
        @inference_methods ||= []
      end

      #
      def self.method_added(name)
        if name.to_s =~ /^infer_/
          inference_methods << name
        end
      end

      #
      attr :project

      #
      attr :root

      # Table of inferable metadata.
      attr :table

      #
      def initialize(project)
        @project = project
        @root    = project.root
        @table   = {}

        infer!
      end

      #
      def infer!
        self.class.inference_methods.each do |meth|
          send(meth)
        end
      end

      #
      def apply(profile)
        table.each do |key, value|
          profile[key] = value unless profile.value?(key)
        end
      end

      # Extract version from VERSION file.
      #--
      # TODO: It might be better to support the VERSION file as a separate class,
      # in the same way as we support README and MANFIEST.
      #
      # TODO: Support for codename?
      #++
      def infer_version_from_version_file
        vfile = root.glob('VERSION{,.txt,.yml,.yaml}', File::FNM_CASEFOLD).first
        if vfile && vfile.exist?
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
            set :version, text
          when :text
            set :version, text
          end
        end
      end

      #
      #--
      # TODO: maybe in meta/ too?
      #++
      def infer_manifest
        if file = root.glob('manifest{,.txt}', :casefold).first
          set :manifest, File.basename(file)
        end
      end

      #
      def infer_from_readme
        readme = project.readme
        set :name, readme.name
        set :title, readme.title
        set :description, readme.description
        set :copyright, readme.copyright
        set :authors, readme.authors
        set :resources, readme.resources
      end

      # Failing to find a name for the project, the last hope
      # is to discern it from the lib files.
      def infer_name_from_lib
        if file = root.glob('lib/*.rb').first
          name = file.basename.to_s.chomp('.rb')
          set :name, name
        end
      end

      private

      #
      def set(name, value)
        if value && @table[name.to_sym].nil?
          @table[name.to_sym] = value 
        end
      end

    end

  end

end

