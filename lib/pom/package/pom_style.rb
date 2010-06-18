class POM::Package

  # Standard POM style PACKAGE file, e.g.
  #
  #   ---
  #   name: pom
  #   vers: 1.0.0.pre.1
  #   date: 2010-10-10
  #   code: POM
  #
  module POMStyle

    #
    def self.match?(data)
      return false unless Hash === data
      data = data.inject({}){|h,(k,v)| h[k.to_s]=v; h}
      !data.keys.include?('major')
    end

    # TODO: Add time to date?
    def render
      out = []
      out << "name: #{name}"
      out << "vers: #{version}"
      out << "date: #{date.strftime('%Y-%m-%d')}"
      out << "code: #{code}"         if code
      out << "nick: #{nick}"         if nick
      out << "path: #{path.inspect}" if path && path != ['lib']
      out.join("\n")
    end

    #
    def parse(data)
      data = data.inject({}){|h,(k,v)| h[k.to_s]=v; h}
      self.name = data['name']
      self.vers = data['vers'] || data['version']
      self.date = data['date']
      self.code = data['code'] || data['codename'] || data['module']
      self.nick = data['nick'] || data['nickname']
      self.path = data['path'] || data['loadpath'] || ['lib']
    end

  end

end
