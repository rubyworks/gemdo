module POM

  # Root directory is indicated by the presence of a +meta/+ directory,
  # or +.meta/+ hidden directory.

  ROOT_INDICATORS = [ '{.meta,meta}/' ]

  # Locate the project's root directory. This is determined
  # by ascending up the directory tree from the current position
  # until the ROOT_INDICATORS is matched. Returns +nil+ if not found.

  def self.root(local=Dir.pwd)
    local ||= Dir.pwd
    Dir.chdir(local) do
      dir = nil
      ROOT_INDICATORS.find do |i|
        dir = locate_root_at(i)
      end
      dir ? Pathname.new(File.dirname(dir)) : nil
    end
  end

  #
  def self.locate_root_at(indicator)
    root = nil
    dir  = Dir.pwd
    while !root && dir != '/'
      find = File.join(dir, indicator)
      root = Dir.glob(find, File::FNM_CASEFOLD).first
      #break if root
      dir = File.dirname(dir)
    end
    root ? Pathname.new(root) : nil
  end

end

