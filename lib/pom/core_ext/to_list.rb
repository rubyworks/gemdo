class String

  def to_list
    split(/[:;\n]/).map(&:strip)
  end

end

module Enumerable

  def to_list
    [to_a].flatten.compact
  end

end

