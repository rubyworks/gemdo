class Object
  alias_method :try_dup, :dup
end

class NilClass
  def try_dup
    self
  end
end

class Symbol
  def try_dup
    self
  end
end

class TrueClass
  def try_dup
    self
  end
end

class FalseClass
  def try_dup
    self
  end
end

class Numeric
  def try_dup
    self
  end
end

