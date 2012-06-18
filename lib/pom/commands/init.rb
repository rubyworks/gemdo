module POM::Commands

  # Create a Profile file if missing.
  class Init

    #
    def self.run
      new.run
    end

    #
    def initialize
      @options = {}
    end

    #
    attr :resources

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "pom init [<resources> ...]"

        opt.on("--replace", "-r", "replace any pre-existing entries") do
          options[:replace] = true
        end

        opt.on("--force", "-f", "override safe-guarded operations") do
          $FORCE = true
        end

        opt.on("--trial", "-n", "run in trial mode, skips disk writes") do
          $TRIAL = true
        end

        opt.on("--debug", "run in debug mode, raises exceptions") do
          $DEBUG   = true
          $VERBOSE = true
        end

        opt.on_tail("--help", "-h", "display this help message") do
          puts opt
          exit
        end
      end

      parser.parse!

      @resources = ARGV
    end

    #--
    # TODO: How to handle options[:replace] ?
    #++
    def execute
      #require 'erb'

      root = Dir.pwd

      #has_profile = POM::Profile.find(root)
      has_profile = Dir.glob('profile{,.yml,.yaml,.rb}', File::FNM_CASEFOLD).first

      if has_profile and not $FORCE       #if POM::Profile.find(root) and not $FORCE
        $stderr << "PROFILE already exists. Use --force option to allow overwrite.\n"
        exit -1
      end

      require_rubygems

      require 'readme'
      require 'pom/gemspec'

      #prime = { 
      #  'name'       => File.basename(root),
      #  'version'    => '0.0.0',
      #  'requires'   => [],
      #  'summary'    => "FIX brief one line description here",
      #  'contact'    => "FIX name <email> or uri",
      #  'authors'    => "FIX names of authors here",
      #  'repository' => "FIX master public repo uri"
      #}

      #current = Dir.glob('**/*', File::FNM_DOTMATCH)

      #if !File.exist?('.ruby')
      #  File.open('.ruby', 'w'){|f| f << `ruby -v`}
      #end

      #has_package = Gemdo::Rubyspec.find(root)

      #if has_profile && !$FORCE
      #  $stderr.puts "Looks like your project is already built on a gemdo."
      #  $stderr.puts "To re-create the metadata files use the --force option."
      #  return
      #end

      #name = File.basename(root)

      project = POM::Project.new(root)

      #name    = project.name || File.basename(root)
#      profile = project.profile

      #if !has_package
      #  #metadata.new_project
      #  metadata.name     = File.basename(root)
      #  metadata.version  = '0.0.0'
      #  metadata.codename = 'FIXME A version codename is optional'
      #end

#      profile.summary  = "FIXME brief one line description here"
#      profile.contact  = "FIXME name <#{ENV['EMAIL']}>"
#      profile.authors << "FIXME list of author's names here"
#      profile.homepage = "FIXME: http://your_website.org"
      #profile.resources.repository = "FIXME: master public repo uri"

      if resources.empty?
        resources << Dir.glob('*.gemspec').first
        resources << Dir.glob('README{,.*}').first
      end

      resources.compact!

      resources.each do |file|
        case file
        when /\.gemspec$/
          text = File.read(file)
          gemspec = /^---/.match(text) ? YAML.load(text) : Gem::Specification.load(file)
          project.import_gemspec(gemspec)
        when /^README/i
          readme = Readme.load(file)
          project.import_readme(readme)
        else
          text = File.read(file)
          obj  = /^---/.match(text) ? YAML.load(text) : text
          case obj
          when ::Gem::Specification
            project.import_gemspec(obj)
          when String
            project.import_readme(obj)
          #when Hash
            #metadata.mesh(obj)
          else
            puts "Cannot convert #{file} (skipped)"
          end
        end
      end

      #project.root = root

      # load any meta entries that may already exist
      #project.reload unless options[:replace]

      #profile_file = profile.file ? profile.file : File.join(root,'PROFILE')

      #if $TRIAL
      #else
      #  #if $FORCE or !(has_package or has_profile)
      #    metadata.backup!
      #    metadata.save! #(package_file)
      #  #end
      #end

      text = project.profile.render
    
      if $TRIAL
        puts text
      else
        File.open('Profile', 'w'){ |f| f << text }

        puts "'Profile' has been created or updated. Please review"
        puts "this file carefully and edit as needed.\n"
      end


      #diff = Dir.glob('**/*', File::FNM_DOTMATCH) - current
      #diff = diff.select{ |f| File.file?(f) }

      #if diff.empty?
      #  puts "Nothing has been done."
      #else
      #  diff.each do |f|
      #    puts "  #{f}"
      #  end
      #end
    end

    #
    #def render_templates(project)
    #  profile = project.profile
    #  ERB.new(template).result(binding)
    #end

    #
    #def print_fixes
    #  root  = Dir.pwd
    #  fixes = []
    # pwd = Pathname.new(root)
    #  files = [Gemdo::Package.find(root), Gemdo::Profile.find(root)]
    #  files.each do |file|
    #    File.readlines(file).each{ |l| l.grep(/FIXME/).each{ |r| fixes << file.relative_path_from(pwd) } }
    #  end
    #  fixes.uniq!
    #  unless fixes.empty?
    #    puts "The following files require editing:\n"
    #    puts "  " + fixes.join("\n  ")
    #  end
    #end

    #
    def require_rubygems
      begin
        require 'rubygems'
        #::Gem::manage_gems
      rescue LoadError
        raise LoadError, "RubyGems is not installed."
      end
    end

  end

end
