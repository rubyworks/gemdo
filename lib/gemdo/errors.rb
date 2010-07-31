module Gemdo

  # = Validation Error
  #
  # This error is raised if Metadata does not
  # meet minimum field requirements, or attempts
  # to set a bad field entry.

  class ValidationError < ArgumentError  # :nodoc:
  end

end

