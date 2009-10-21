require 'pathname'

class Pathname

  #
  def glob(match, *opts)
    flags = 0
    opts.each do |opt|
      case opt when Symbol, String
        flags += ::File.const_get("FNM_#{opt}".upcase)
      else
        flags += opt
      end
    end
    Dir.glob(::File.join(self.to_s, match), flags).collect{ |m| self.class.new(m) }
  end

  #
  def first(match, *opts)
    flags = 0
    opts.each do |opt|
      case opt when Symbol, String
        flags += ::File.const_get("FNM_#{opt}".upcase)
      else
        flags += opt
      end
    end
    file = ::Dir.glob(::File.join(self.to_s, match), flags).first
    file ? self.class.new(file) : nil
  end

  #
  alias_method :/, :+

end

