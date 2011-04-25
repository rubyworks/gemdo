require 'pom/profile/property'

module POM

  # Project's <i>packaging name</i>. It can default to title downcased,
  # if not supplied.
  property :name do
    parse do |value|
      value.to_s.downcase.sub(/[^A-Za-z0-9_-]+/, '-')
    end
  end

  # Version number.
  property :version do
    parse do |value|
      VersionNumber.new(value)
    end
    validate do |value|
      true  # TODO
    end
  end

  # Date this metadata was generated.
  property :date do
    parse do |val|
      case val
      when Time, Date, DateTime
        val
      else
        Time.parse(val) if val
      end
    end
  end

  # Title of package (this defaults to project name capitalized).
  property :title do
    parse do |value|
      value.to_s #.capitalize #titlecase
    end
    #default do
    #  name.to_s.capitalize #titlecase
    #end
  end

  # A one-line brief description.
  property :summary do
    default do
      d = description.to_s.strip
      i = d.index(/(\.|$)/)
      i = 69 if i > 69
      d[0..i]
    end
  end

  # Detailed description.
  property :description

  # Colorful nick name for the particular version, e.g. "Lucid Lynx".
  property :codename do
    aliases :code
  end

  # Namespace for this program. This is only needed if it is not the default
  # of the +name+ capitalized and/or the toplevel namespace is not a module.
  # For example, +activerecord+  uses +ActiveRecord+ for it's namespace,
  # not Activerecord.
  property :namespace do
    parse do |ns|
      case ns
      when /^class/, /^module/
        ns.strip
      else
        "module #{ns.strip}"
      end
    end
  end

  # Internal load paths.
  property :loadpath do
    aliases :path, :require_paths
    parse do |path|
      case path
      when NilClass
        ['lib']
      when String
        path.split(/[,:;\ ]/)
      else
        path.to_a
      end
    end
    default ['lib']
  end

  # Access to manifest list or file name.
  property :manifest do
    parse do |file|
      file.to_s
    end
  end

  # The SCM which the project is currently utilizing.
  property :scm

  # List of requirements.
  property :requires do
    aliases :requirements, :dependencies, :gems
    parse do |list|
      PackageList.new(list)
    end
    default { PackageList.new }
  end

  # List of packages with which this project cannot function.
  property :conflicts do
    parse do |list|
      PackageList.new(list)
    end
    default { PackageList.new }
  end

  # List of packages that this package can replace (approx. same API).
  property :replaces do
    parse do |list|
      PackageList.new(list)
    end
    default { PackageList.new }
  end

  # The Ruby engine and versions required by the project.
  property :engines do
    parse do |list|
      PackageList.new(list)
    end
    default { PackageList.new }
  end

  # The post-installation message.
  property :message

  # Name of the user-account or master-project to which this project
  # belongs. The suite name defaults to the project name if no entry
  # is given. This is also aliased as #collection.
  property :suite do
    aliases :collection
  end

  # Organization.
  property :organization do
    aliases :company
  end

  # Official contact for this project. This is typically
  # a name and email address.
  property :contact

  # The date the project was started.
  property :created

  # Copyright notice. Eg. "Copyright (c) 2009 Thomas Sawyer"
  property :copyright do
    default do
      "Copyright #{Time.now.strftime('%Y')} #{authors.first}"
    end
  end

  # List of license, e.g. 'Apache 2.0'.
  property :licenses do
    parse do |value|
      [value].flatten
    end
    default []
  end

  # List of authors.
  property :authors do
    parse do |value|
      [value].flatten
    end
    default []
  end

  # List of maintainers.
  property :maintainers do
    parse do |value|
      [value].flatten
    end
    default []
  end

  # Table of project URLs encapsulated in a Resources object.
  property :resources do
    parse do |value|
      Resources.new(value || {})
    end
    default do
      Resources.new
    end
  end

  # Returns a Hash of +Type+ => +URI+ for SCM repository.
  property :repositories do
    default {{}}  # Repositories.new
  end

end

