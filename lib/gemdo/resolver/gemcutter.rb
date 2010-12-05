module Gemdo

  class Resolver

    require 'gemdo/resolver/source'

    #
    class GemCutter

      #
      attr :project_gem

      #
      attr :missing

      #
      #attr :available

      #
      #attr :matches

      #
      attr :cache

      #
      def initialize(project_gem)
        require 'open-uri'

        @project_gem  = project_gem

        @missing      = []
        @cache        = {}
      end

      # Access to +@cache+ plus current project.
      def gems
        @gems ||= (
          @cache.merge(project_gem.name=>[project_gem])
        )
      end

      # Featch all potetnial gems for the +project_gem+.
      def fetch
        fetch_requirements(project_gem.dependencies)
      end

      # Fetch all versions of all gems in given requirments and their 
      # sub-requirements. This builds up the gem +@cache+ with Gem instances.
      def fetch_requirements(requirements)
        return if requirements.empty?

        names = requirements.map{ |name, constraint| name }
        names = names.reject{ |name| already_fetched?(name) }
        names = names.uniq

        gems = get(*names)

        requirements.each do |name, constraint|
          next if already_fetched?(name)
          unless gems.find{ |gem| gem.name == name }
            self.missing << [name, constraint]
          end
        end

        fetch_requirements(unfetched_requirements(gems))
      end

      #
      def get(*names)
        names = names - @cache.keys # remove names already fetched
        return [] if names.empty?
        url = "http://rubygems.org/api/v1/dependencies?gems=#{names.join(',')}"
        $stderr.puts "fetching #{url}" if ($DEBUG or $VERBOSE)
        gems = Marshal.load(open(url))
        gems = gems.map{ |gem| Gem.new(gem) }
        gems.each do |gem|
          @cache[gem.name] ||= []
          @cache[gem.name] << gem
        end
        #@cache.merge!(gems.group_by{ |gem| gem[:name] })
        return gems
      end

      #
      def unfetched_requirements(gems)
        reqs = []
        gems.each do |gem|
          gem.dependencies.each do |name, constraint|
            reqs << [name, constraint] unless already_fetched?(name)
          end
        end
        reqs.uniq
      end

      # Has a gem already been fetched?
      def already_fetched?(name)
        @cache.key?(name)
      end

    end

  end

end
