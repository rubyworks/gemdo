class Rock::Metadata

  # Contact's email address.
  class EMail < String

    # Regular expression for matching valid email addresses.
    RE_EMAIL = /\b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i  #/<.*?>/

    #
    def self.store
      "yaml:profile.yml"
    end

    #
    def self.default(metadata)
      contact = metadata.contact
      if md = RE_EMAIL.match(contact.to_s)
        md[0]
      else
        nil
      end
    end

    #
    include AbstractField

  end

end

