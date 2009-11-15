module POM

  # = Debian Control File Model
  #
  class DebCtrl

    # Some debian fields not yet used yet.
    #   Installed-Size: 1024
    #   Replaces: sam-sheepdog
    #   Pre-Depends: perl, ...
    #   Suggests: docbook

    # Debian control attributes.

    attr_accessor :package, :version, :priority, :architecture,
                  :essential, :section, :depends, :recommends,
                  :conflicts, :maintainer, :provides, :description,
                  :detail

    def initialize
      @priority   = 'optional'
      @essential  = 'no'
      @depends    = []
      @recommends = []
      @conflicts  = []
      @provides   = []
    end

    # Text output.

    def to_s
      ctrl = ''
      ctrl << "Package: #{package}\n"
      ctrl << "Version: #{version}\n"
      ctrl << "Priority: #{priority}\n"
      ctrl << "Architecture: #{architecture}\n"
      ctrl << "Essential: #{essential}\n"
      ctrl << "Section: #{section}\n" if section
      ctrl << "Depends: #{depends.join(', ')}\n"
      ctrl << "Recommends: #{recommends.join(' | ')}\n" unless recommends.empty?
      ctrl << "Conflicts: #{conflicts.join(', ')}\n" unless conflicts.empty?
      ctrl << "Maintainer: #{maintainer}\n"
      ctrl << "Provides: #{provides.join(', ')}\n" unless provides.empty?
      ctrl << "Description: #{description}\n"
      ctrl << " #{detail}\n"
      ctrl
    end

    # Create debian control from a sow specification.
    #--
    # TODO Do we need to ensure a ruby version dependency?
    #++

    def self.from_pom( metadata )
      ctrl = new

      name = metadata.name.downcase.gsub(/\W+/,'').gsub(/_/,'')
      rver = RUBY_VERSION.sub(/[.][0-9]+$/,'')

      ctrl.package      = "lib#{name}-ruby#{rver}"
      ctrl.version      = metadata.version
      ctrl.maintainer   = metadata.contact
      ctrl.description  = metadata.summary
      ctrl.detail       = metadata.description
      ctrl.architecture = (metadata.arch == 'any' ? 'all' : sow.arch)

      if metadata.package.key?('debian')
        pkg = metadata.package.send(:merge, sow.package.debian)
      else
        pkg = sow.package
      end

      dep = pkg.dependencies.collect{ |d, v|
        if v
          ctrl.depends << "lib#{d} (#{v})"
        else
          ctrl.depends << "lib#{d}"
        end
      }.join(', ')

      ctrl.section      = pkg.category
      ctrl.recommends   = pkg.recommends
      ctrl.conflicts    = pkg.conflicts
      ctrl.provides     = pkg.provides

      #ctrl.priority
      #ctrl.essential

      ctrl
    end


  end

end
