module Rock::Commands

  class Init

    def self.run
      new.run
    end

    #
    def initialize
      #@project = Rock::Project.new(:lookup=>true)
      @options = {}
    end

    #
    attr :resources
    attr :options

    #
    def run
      parse
      execute
    end

    #
    def parse
      parser = OptionParser.new do |opt|
        opt.banner = "rock init [RESOURCE ...]"

        opt.on("--replace", "-r", "replace any pre-existing entries") do
          options[:replace] = true
        end

        opt.on("--force", "-f", "override safe-guarded operations") do
          $FORCE = true
        end

        opt.on("--trial", "run in trial mode, skips disk writes") do
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
      require_rubygems

      require 'rock/metadata'
      require 'rock/readme'
      require 'rock/gemspec'

      root = Dir.pwd

      #prime = { 
      #  'name'       => File.basename(root),
      #  'version'    => '0.0.0',
      #  'requires'   => [],
      #  'summary'    => "FIX brief one line description here",
      #  'contact'    => "FIX name <email> or uri",
      #  'authors'    => "FIX names of authors here",
      #  'repository' => "FIX master public repo uri"
      #}

      has_package = Rock::Package.find(root)
      has_profile = Rock::Profile.find(root)
      has_rubydir = Rock::RubyDir.find(root)

      #if Rock::Package.find(root) and not $FORCE
      #  $stderr << "PACKAGE file already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      #if Rock::Profile.find(root) and not $FORCE
      #  $stderr << "PROFILE already exists. Use --force option to allow overwrite.\n"
      #  return
      #end

      name = File.basename(root)

      project = Rock::Project.new(root) #, :name=>name)
      rubydir = Rock::RubyDir.new(root)
      package = Rock::Package.new(root)

      name = rubydir.name || package.name || File.basename(root)

      profile = Rock::Profile.new(root, name)

      if !has_package
        #package.name    = name # ???
        package.version  = '0.0.0'
        package.code     = 'FIXME A version code name is optional'
      end

      if !has_profile
        profile.summary  = "FIXME brief one line description here"
        profile.contact  = "FIXME name <email> or uri"
        profile.authors << "FIXME list of author's names here"

        profile.resources.homepage   = "FIXME: main website address"
        profile.resources.repository = "FIXME: master public repo uri"
      end

      #metadata.new_project

      files = resources()
      if files.empty? && !has_package && !has_rubydir
        files << Dir.glob('*.gemspec').first
        files << Dir.glob('README{,.*}').first
      end
      files.compact!

      files.each do |file|
        case file
        when /\.gemspec$/
          text = File.read(file)
          gemspec = /^---/.match(text) ? YAML.load(text) : Gem::Specification.load(file)
          project.import_gemspec(gemspec)
        when /^README/i
          readme = Rock::Readme.load(file)
          project.import_readme(readme)
        when /^PACKAGE/
          rubydir.load_from_package(package)
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

      #
      if !has_rubydir
        rubydir.load_from_package(package)
      end

      #project.root = root

      # load any meta entries that may already exist
      #project.reload unless options[:replace]

      #package_file = package.file ? package.file : File.join(root,'PACKAGE')
      #profile_file = profile.file ? profile.file : File.join(root,'PROFILE')

      if $TRIAL
      else
        if $FORCE or !has_rubydir
          rubydir.save!
        end

        if $FORCE or !has_package
          package.backup!
          package.save! #(package_file)
        end

        if $FORCE or !has_profile
          profile.backup!
          profile.save! #(profile_file)
        end
      end

      print_fixes
    end

    #
    def print_fixes
      root  = Dir.pwd
      fixes = []
      pwd = Pathname.new(root)
      files = [Rock::Package.find(root), Rock::Profile.find(root)]
      files.each do |file|
        File.readlines(file).each{ |l| l.grep(/FIXME/).each{ |r| fixes << file.relative_path_from(pwd) } }
      end
      fixes.uniq!
      unless fixes.empty?
        puts "The following files require editing:\n"
        puts "  " + fixes.join("\n  ")
      end
    end

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
