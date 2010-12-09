# TODO: Bring the Bundler Gemfile and the POM Gemfile in mroe name alignment.

# TODO: Should the date be specififed?

# TODO: Do we need quite so many aliases?

require 'bundler/dsl'

module POM
  GEMFILE_ATTRIBUTES = [
    :name,
    :version,
    :codename, :code,
    :date, :release_date, :released,
    :namespace,
    :loadpath, :path,
    :requires, :requirements, :conflicts, :replaces, :provides,
    :manifest
  ]
end

# This Bundler extension allows POM to use the Gemfile for project
# metadata beyond dependency requirements.
module Bundler
  class Dsl
    # Where as POM can handle some project packaging metadata.
    # Bundler can just ignore these (at least for now).
    def method_missing(s, *a, &b)
      if !POM::GEMFILE_ATTRIBUTES.include?(s)
        super(s, *a, &b)
      end
    end

    def self.evaluate(gemfile, lockfile, unlock)
      text = Bundler.read_file(gemfile.to_s)
      if  /\A---/ =~ text
        builder = from_yaml(text)
      else
        builder = new
        builder.instance_eval(text, gemfile.to_s, 1)
      end
      builder.to_definition(lockfile, unlock)
    end

    #
    def self.from_yaml(text)
      require 'yaml'
      data = YAML.load(text)
      from_hash(data)
    end

    #
    def self.from_hash(data)
      builder = new
      data.each do |key, value|
        case key.to_s
        when 'requires', 'requirements'
          value.each do |entry|
            entry = parse_gem(entry)
            builder.gem(*entry)
          end
        #when 'conflicts'
        #  value.each do |entry|
        #    builder.gem(entry)
        #  end
        else
          builder.__send__(key, value)
        end
      end
      builder
    end

    OP_TRANS = {'+'=>'>=', '-'=>'<', '~'=>'~>'}

   # TODO: make the gem method smarter in Bundler itself
    def self.parse_gem(entry)
      if String === entry
        entry.gsub!(/([>=<])\ /, '\1')
        parts = entry.split(/\s+/)
        name  = parts.shift
        if parts.last =~ /\((.*?)\)/
          parts.pop
          group = $1.split(/\s+/)
        end
        parts.map! do |part|
          if md = /^(.*?)([+-~])$/.match(part)
            OP_TRANS[md[2]] + md[1]
          else
            part
          end
        end
        entry = [name] + parts
        entry << {:group=>group} if group
        entry
      else
        entry
      end
    end

  end
end
