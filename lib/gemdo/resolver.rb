module Gemdo

  require 'gemdo/resolver/rubygems'
  require 'gemdo/resolver/gemcutter'

  # The Resolver class takes the project requirements list
  # and resolves the dependencies against a gem source.
  #
  # It can be used to determines if the current load environment
  # satisfies the requirements or to produce a lock file based
  # on Rubygems.org.
  #
  #--
  # TODO: Do we need a way to limit to certain dependency groups?
  # TODO: Gemcutter API does not separate runtime and development.
  # TODO: Platform is not being taken into consideration.
  #++
  class Resolver

    # Gemdo::Project instance.
    attr_reader :project

    # Include runtime dependencies only.
    attr_accessor :runtime

    # Include prereleases.
    attr_accessor :prerelease

    # Resolve against local gems.
    attr_accessor :local

    # Output format (default, lock or requests)
    attr_accessor :format

    # Gem source (e.g. local gems or gemscutter).
    attr :source

    #
    def initialize(root, options={})
      @project = Project.new(root)
      options.each do |k,v|
        __send__("#{k}=", v)
      end
    end

    #
    def project_gem
      @project_gem ||= Gem.new(:name=>project.name, :number=>project.version, :dependencies=>requirements)
    end

    #
    def setup
      if local
        @source = Rubygems.new(project_gem)
      else
        @source = GemCutter.new(project_gem)
      end      

      # fetch all gems that could be used
      #source.fetch_requirements(requirements)
      @source.fetch

      # Exclude prereleases unless +prerelease+ option is active.
      if !prerelease
        @source.cache.each do |name, gems|
          gems.reject!{ |gem| /[A-Za-z]/ =~ gem.number }
        end
      end

      # create a dependency graph by applying constraints
      @source.gems.each do |name, gems|
        gems.each do |gem|
          gem.apply_constraints(@source.gems)
        end
      end

      case format
      #when :requests
      when :breakdown
        produce_dependency_breakdown(source)
      else
        produce_dependency_lockdown(source)
      end
    end

    # Navigate graph until complete route is found.
    def resolve
      picks = {}
      resolve_gem(project_gem, picks)
      picks.values.map{ |pick| pick.gem }
    end

    #
    def produce_dependency_breakdown(source)
      source.gems.each do |name, gems|
        puts "#{name}"
        gems.each do |gem|
          puts "  #{gem.number}"
          gem.dependencies.each do |(depname, constraint)|
            puts "    #{depname} #{constraint}"
          end
        end
      end
      puts
      puts "MISSING"
      source.missing.each do |name, constraint|
        puts "  #{name} #{constraint}"
      end
    end

    # TODO: traverse resolved dependencies and find missing matches for actual missing.
    def produce_dependency_lockdown(source)
      matches = resolve

      $stderr.puts "(#{matches.size} gems)"

      matches = matches.group_by{ |g| g.name }

      matches.each do |name, gems|
        vers = gems.map{ |gem| gem.number }.sort.reverse
        print(name, vers)
      end

      #source.missing.each do |name, constraint|
      #  print(name, [constraint])
      #end
    end

    #
    def requirements
      @requirements ||= (
        if runtime
          project.requirements.production.map do |req|
            [req.name, req.constraint.to_s]
          end
        else
          project.requirements.map do |req|
            [req.name, req.constraint.to_s]
          end
        end
      )
    end

    #
    def resolve_gem(main_gem, picks)
      main_gem.resolved.each do |name, gem_choices|
        next if gem_choices.size == 0
        if pick = picks[name]
          if gem_choices.find{ |g| g == pick.gem }
            # we're good!
          else
            # damn! reset picks and try another
            if bump = pick.bump
              picks = pick.reset
              picks[name] = bump
              resolve_gem(bump.gem, picks)
            else
              master_pick = picks[pick.master.name]
              if bump = master_pick.bump
                picks = master_pick.reset
                picks[pick.master.name] = bump
                resolve_gem(bump.gem, picks)
              else
                raise "no possible resolution"
              end
            end
          end
        else
          gem_index   = 0
          gem_choice  = gem_choices[gem_index]
          picks[name] = Pick.new(main_gem, gem_index, gem_choice, picks)
          resolve_gem(gem_choice, picks)
        end
      end
    end

    # Apply requirements to table, elminating version that do not satisfy
    # the version constraints.
    #def apply_constraints(requirements)
    #  matches = []
    #  requirements.each do |name, constraint|
    #    gems = available_versions.select{ |gem| gem[:name] == name }
    #    gems = gems.select{ |gem| gem[:number].match?(constraint) }
    #    matches.concat(gems)
    #  end
    #  matches
    #end    

    # Output resolution. Make sure versions are sorted from most to least recent.
    def print(name, versions)
      if format == :lock
        puts "gem '%s', '= %s'" % [name.to_s, versions.first]
      else
        puts "%s (%s)" % [name.to_s, versions.join(", ")]
      end
    end

    # Instead of using a Hash as given by the url api, we encapsulate each 
    # library as a Gem object.
    class Gem
      attr :name
      attr :number
      attr :dependencies
      attr :platform

      # Hash of resolved dependencies.
      attr :resolved

      #
      def initialize(settings)
        @name         = settings[:name]
        @number       = VersionNumber.new(settings[:number])
        @platform     = settings[:platform]
        @dependencies = settings[:dependencies]

        @resolved     = {} #Hash.new{|h,k|h[k]=[]}
      end

      # Apply dependencies, elminating versions that do not satisfy
      # the version constraints.
      def apply_constraints(available_gems)
        dependencies.each do |name, constraint|
          resolved[name] = (available_gems[name] || []).dup
        end
        dependencies.each do |name, constraint|
          resolved[name].reject!{ |gem| !gem.number.match?(constraint) }
        end
        dependencies.each do |name, constraint|
          resolved[name].sort!{ |a,b| b.number <=> a.number }
        end
      end
      def inspect
        "#{name} #{number}"
      end
    end

    # When resolving dependencies, a Pick is used to encapsulate a 
    # dependency choice. In other words, if a requirement can be satisfied
    # by multiple gems, the latest version is picked, placed in an instance of
    # Pick along with a snapshot of the current state of all picks (resolution)
    # at that moment. If later a conflict occurs which traces back to a pick,
    # the pick can reset the reslution state and try a different pick.
    class Pick
      attr :master
      attr :index
      attr :gem
      attr :reset
      def initialize(master, index, gem, reset)
        @master     = master
        @index      = index
        @gem        = gem
        @reset      = reset.dup
      end
      def name
        gem.name
      end
      def bump
        gem = master.resolved[name][index+1]
        if gem
          Pick.new(master, index+1, gem, reset)
        else
          nil # none left to try
        end
      end
      def inspect
        "(#{master.inspect} -> #{gem.inspect})"
      end
    end

  end

end

