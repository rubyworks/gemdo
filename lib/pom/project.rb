require 'facets/pathname'
require 'pom/metadata'
require 'pom/project/manifest'
require 'pom/project/history'

module POM

  # The Project class provides the location of specific
  # directories and files in the project, plus access
  # to the projects metadata, etc.
  #
  class Project

    #
    LIB_DIRECTORY   = Pathname.new(File.dirname(File.dirname(__FILE__)))

    #
    ROOT_INDICATORS = ['{.,_}root', '{meta/,metadata*}']

    #
    README = "readme{,.txt}"

    #
    def initialize
      @root   = locate_root || raise("can't locate project root")

      # DEPRECATE, or use for ?
      @admin  = root  #.glob_first('{,_}admin', :casefold) || root

      @cache  = root + '.cache'

      if (root + '.config').directory?
        @config = root + '.config'
      else
        @config = root + 'config'
      end

      @task  = root + "task"

      #@build = cache + 'build'

      #@log     = root + 'log'
      #@pkg    = root.glob_first('pkg') || cache + 'pkg'

      #else
      #  @config  = root.glob_first('config') || admin + 'config'
      #  @local   = root.glob_first('.local') || admin + 'local'
      #  @build   = root.glob_first('build')  || admin + 'build'
      #  @log    = root.glob_first('log')    || admin + 'log'
      #  @pkg     = root.glob_first('{pack,packs,pkg}')  ||
      #             admin.glob_first('{pack,packs,pkg}') ||
      #             admin + 'pack'
      #end

      #@config_reap = config + 'reap'

      @source  = root

      # TODO: Not sure about this location. Where should plugins go?
      @plugin = root + 'plugins/reap'

      #@tmp    = Pathname.new(File.join(Dir.tmpdir, 'reap'))
      #@tmp     = @cache + 'tmp'
    end

    # Metadata provides all the general information about the project.
    def metadata
      @metadata ||= Metadata.new(root)
    end

    # Project manifest.
    def manifest
      @manifest ||= Manifest.new(root)
    end

    def history
      @history ||= History.new(root)
    end

    # Project manifest file.
    # TODO: Depreacate in favor of using manifest.file
    def manifest_file
      root.glob_first('manifest{,.txt}', :casefold)
    end

    # Project's root location. By default this is determined by scanning
    # up from the current working directory in search of the ROOT_INDICATOR.
    attr :root

    # Project's admin directory. This is the same as root. It used to be
    # different, but that use is being deprecated.
    # TODO: DEPRECATE admin directory.
    attr :admin

    # Log directory.
    def log
      @log ||=(
        dir = root.glob_first('{log,doc/log}{,s}') || root + 'doc/log'
        dir.mkdir_p unless dir.exist?
        dir
      )
    end

    # Package directory.
    def pack
      @pkg ||=(
        dir = root.glob_first('{pack,pkg}{,s}') || cache + 'pkg'
        dir.mkdir_p unless dir.exist?
        dir
      )
    end
    alias_method :pkg, :pack

    # Temporary directory.
    def tmp
      @tmp ||=(
        dir = root.glob_first('tmp') || cache + 'tmp'
        dir.mkdir_p unless dir.exist?
        dir
      )
    end
    alias_method :tmpdir, :tmp

    # Configuration directory.
    attr :config

    # Task directory.
    attr :task

    # Config '.config/reap'
    #attr :config_reap

    # Cache directory.
    attr :cache

    # Plugin directory.
    attr :plugin

    # Location of project source code. Currently, this is always
    # the same as the root.
    #
    # TODO: Support alternate source location in the future (?)
    attr :source

    # Reap services configuration folder.
    #attr :reap_services_folder

    # Reap services configuration file.
    #attr :reap_services_file

    # About project notice.
    #
    def about(parts) #(*parts)
      if parts.empty?
        puts
        puts "  #{metadata.title} #{metadata.version} (#{metadata.released})"
        puts "  #{metadata.abstract}"
        puts "  " + metadata.homepage
        puts
        puts "  " + metadata.description
        puts
        puts "  Copyright #{metadata.copyright}"
        puts
      else
        parts.each do |field|
          case field
          #when 'settings'
          #  y settings
          when 'metadata'
            y metadata
          else
            puts metadata.send(field)
          end
        end
      end
    end

    # Project release announcement built on README.
    #
    def announcement(file=nil, options={})
      header = options[:header]

      if file = Dir.glob(file, File::FNM_CASEFOLD).first
        ann = File.read(file)
      else
        release = history.release.to_s

        ann = []
        if file = Dir.glob(README, File::FNM_CASEFOLD).first
          readme  = File.read(file).strip
          readme  = readme.gsub("Please see HISTORY file.", '=' + release)
          ann << readme
        else
          if header
            ann << "#{metadata.title} #{metadata.version} has been released."
            ann << ''
            ann << "* #{metadata.homepage}"
            ann << ''
            ann << "#{metadata.description}"
            ann << ''
          end
          ann << release
        end
        ann = ann.join("\n")
      end
      ann.unfold
    end

    private

      # Locate the project's root directory. This is determined
      # by ascending up the directory tree from the current position
      # until the ROOT_INDICATOR is matched. Returns +nil+ if not found.
      #
      def locate_root
        dir = nil
        ROOT_INDICATORS.find do |i|
          dir = locate_root_at(i)
        end
        return dir
      end

      #
      def locate_root_at(indicator)
        root = nil
        dir  = Dir.pwd
        while dir != '/'
          find = File.join(dir, indicator)
          file = Dir.glob(find, File::FNM_CASEFOLD).first
          if file
            root = Pathname.new(File.dirname(file))
            break
          else
            dir = File.dirname(dir)
          end
        end
        return root
      end

  end#class Project

end#module Reap

