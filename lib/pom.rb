require 'pom/project'

module POM

  # Raw access to project metedata, e.g. VERSION.
  def self.const_missing(name)
    file = File.dirname(__FILE__) + "/pom/meta/#{name.to_s.downcase}"
    if File.exist?(file)
      File.read(file).strip
    else
      super(name)
    end
  end

end

