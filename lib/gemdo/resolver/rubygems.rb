module Gemdo

  class Resolver

    require 'gemdo/resolver/source'

    # Local Rubygems Source.
    class Rubygems < Source

      #
      attr :project_gem

      #
      attr :missing

      #
      attr :cache

      #
      def initialize(project_gem)
        unless defined?(::Gem)
          raise "No library manager loaded."
        end

        @project_gem = project_gem

        @missing = []
        @cache   = {}
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
            self.missing.uniq!
          end
        end

        fetch_requirements(unfetched_requirements(gems))
      end

      #
      def get(*names)
        names = names - @cache.keys # remove names already fetched
        return [] if names.empty?

        gems = names.map{ |name|
          ::Gem.source_index.find_name(name)
        }.flatten

        gems = gems.map do |gem|
          Gem.new(
            :name=>gem.name,
            :number=>gem.version.to_s,
            :dependencies=>gem.dependencies.map{ |d| [d.name, d.requirement.to_s] }
          )
        end

        gems.each do |gem|
          @cache[gem.name] ||= []
          @cache[gem.name] << gem
        end

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




=begin

      #
      def resolve_dependencies(requirements)
        requests = []
        matches  = []
        missing  = []

        requirements.each do |name, constraint|
          gem_dep  = Gem::Dependency.new(name, [constraint])
          rubygems_resolve_gem(gem_dep, requests, matches, missing)
        end

        libs = matches.group_by{ |spec| spec.name }

        requests.each do |name, constraint|
          next unless libs[name]
          libs[name].reject! do |spec|
            !Gemdo::VersionNumber.new(spec.version.to_s).match?(constraint.to_s)
          end
        end

        return libs, missing
      end

      #
      def rubygems_resolve_gem(gem_dep, requests=[], matches=[], missing=[])
        requests << [gem_dep.name, gem_dep.requirement]
        list = Gem.source_index.find_name(gem_dep.name, gem_dep.requirement)
        missing << gem_dep if list.empty?
        matches.concat(list)
        list.each do |spec|
          next if matches.include?(spec)
          spec.runtime_dependencies.each do |dep_gem|
            next if missing.include?(gem_dep)
            rubygems_resolve_gem(dep_gem, matches, missing)
          end
          spec.development_dependencies.each do |dep_gem|
            next if missing.include?(gem_dep)
            rubygems_resolve_gem(dep_gem, matches, missing)
          end unless runtime
        end
      end
=end


=begin
    #
    def rubygems_resolve(requirements)
      requests = []
      matches  = []
      missing  = []
      requirements.each do |name, constraint|
        gem_dep  = Gem::Dependency.new(name, [constraint])
        rubygems_resolve_gem(gem_dep, requests, matches, missing)
      end
      libs = matches.group_by{ |spec| spec.name }
      requests.each do |name, constraint|
        next unless libs[name]
        libs[name].reject! do |spec|
          !Gemdo::VersionNumber.new(spec.version.to_s).match?(constraint.to_s)
        end
      end
      return libs, missing
    end

    #
    def rubygems_resolve_gem(gem_dep, requests=[], matches=[], missing=[])
      requests << [gem_dep.name, gem_dep.requirement]
      list = Gem.source_index.find_name(gem_dep.name, gem_dep.requirement)
      missing << gem_dep if list.empty?
      matches.concat(list)
      list.each do |spec|
        next if matches.include?(spec)
        spec.runtime_dependencies.each do |dep_gem|
          next if missing.include?(gem_dep)
          rubygems_resolve_gem(dep_gem, matches, missing)
        end
        spec.development_dependencies.each do |dep_gem|
          next if missing.include?(gem_dep)
          rubygems_resolve_gem(dep_gem, matches, missing)
        end unless runtime
      end
    end
=end

