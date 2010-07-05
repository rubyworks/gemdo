class POM::Package

  # Jeweler-esque POM style PACKAGE file, e.g.
  #
  #   ---
  #   name : pom
  #   major: 1
  #   minor: 0
  #   patch: 0
  #   build: pre.1
  #   date : 2010-10-10
  #   code : POM
  #
  module JPOMStyle

    #
    def self.match?(data)
      return false unless Hash === data
      data = data.inject({}){|h,(k,v)| h[k.to_s]=v; h}
      return false unless data.keys.include?('major')
      keys = data.keys - %w{major minor patch build}
      return false if keys.empty?  # jeweler style
      return true
    end

    # TODO: Add time to date?
    def render
      out = []
      out << "name : #{name}"
      out << "major: #{major}"
      out << "minor: #{minor}"
      out << "patch: #{patch}"
      out << "build: #{build}" if build && !build.empty?
      out << "date : #{date.strftime('%Y-%m-%d')}"
      out << "code : #{code}"         if code
      out << "nick : #{nick}"         if nick
      out << "path : #{path.inspect}" if path && path != ['lib']
      out.join("\n")
    end

    #
    def parse(data)
      data = data.inject({}){|h,(k,v)| h[k.to_s]=v; h}
      self.name = data['name']
      self.vers = data.values_at('major','minor','patch','build').compact
      self.date = data['date']
      self.code = data['code'] || data['codename'] || data['module']
      self.nick = data['nick'] || data['nickname']
      self.path = data['path'] || data['loadpath'] || ['lib']
    end

  end

end
