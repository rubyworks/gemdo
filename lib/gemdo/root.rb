require 'gemdo/core_ext/pathname'

module Gemdo

  # Root directory is indicated by the presence of either a
  # .ruby file or as a fallback a lib/ directory.
  ROOT_INDICATORS = ['.ruby', '.git', '.hg', '_darcs', 'lib/']

  # Locate the project's root directory. This is determined
  # by ascending up the directory tree from the current position
  # until the ROOT_INDICATORS is matched. Returns +nil+ if not
  # found.
  def self.root(local=Dir.pwd)
    local ||= Dir.pwd
    Dir.chdir(local) do
      dir = nil
      ROOT_INDICATORS.find do |i|
        dir = locate_root_at(i)
      end
      dir ? Pathname.new(dir) : nil
    end
  end

  # This method supplements #root. It does the actual
  # ascention for each root indicator.
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

end

