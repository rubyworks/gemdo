module Gemdo

  class Resolver

    # Resolver source base class.
    class Source


      # List all possible dependencies for a given gem +name+, or
      # all gems if no +name+ is specified.
      def dependencies(name=nil)
        deps = []
        if name
          @cache[name].each do |gem|
            deps.concat(gem.dependencies)
          end
        else
          @cache.each do |name, gems|
            gems.each do |gem|
              deps.concat(gem.dependencies)
            end
          end
        end
        deps.uniq
      end

    end

  end

end

