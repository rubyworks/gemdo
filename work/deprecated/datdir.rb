class FileStore

 private

  def initialize(dir)
    @dir = dir
  end

  def method_missing(name, *a, &b)
    name = name.to_s
    @data[name] ||= _read(name)
  end

  def _read(name)
    file = File.join(@dir,name)
    if File.directory?(file)
      self.class.new(file)
    else
      File.read(file)
    end
  end

end
