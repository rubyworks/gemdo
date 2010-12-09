require 'pom/core_ext/pathname'

module POM

  # Root directory is indicated by the presence of either a
  # .ruby file or as a fallback a lib/ directory.
  ROOT_INDICATORS = ['.rubyspec', '.ruby', '.git', '.hg', '_darcs', 'lib/']

  # Locate the project's root directory. This is determined
  # by ascending up the directory tree from the current position
  # until a root indicator is matched. Returns +nil+ if not
  # found.

  def self.root(dir=Dir.pwd)
    dir  = File.expand_path(dir)
    home = File.expand_path('~')  # Better way?
    ROOT_INDICATORS.find do |marker|
      while dir != home && dir != '/'
        if File.exist?(File.join(dir, marker))
          break dir
        else
          dir = File.dirname(dir)
        end
      end
    end
    dir ? Pathname.new(dir) : nil
  end

=begin
  def self.locate_root_at(indicator)
    root = nil
    dir  = Dir.pwd
    while !root && dir != '/'
      find = File.join(dir, indicator)
      mark = Dir.glob(find, File::FNM_CASEFOLD).first
      root = dir if mark
      dir = File.dirname(dir)
    end
    root ? Pathname.new(root) : nil
  end
=end

end

