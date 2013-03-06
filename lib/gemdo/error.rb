module GemDo

  # Error tag module.
  module Error
  end

  #
  class ProjectNotFound < RuntimeError
    include Error
  end

end

