module POM

  # = VersionNumber
  #
  # VersionNumber is a simplified form of a tuple desgined
  # specifically for dealing with version numbers.
  #
  class VersionNumber
    include Enumerable
    include Comparable

    # Possible build states
    STATES = ['alpha', 'beta', 'pre', 'rc']

    # Shortcut for creating a new verison number
    # given segmented elements.
    #
    #   VersionNumber[1,0,0].to_s  #=> "1.0.0"
    #
    def self.[](*args)
      new(args)
    end

    # Create a new VersionNumber.
    #
    # version - a String, Hash, or Array.
    #
    # Returns a new VersionNumber object.
    def initialize(version)
      case version
      when String
        version = version.split('.')
        @segments = version.map{ |s| /\d+/ =~ s ? s.to_i : s }
      when Hash
        version - version.inject({}){|h,(k,v)| h[k.to_sym] = v; h}
        version = version.values_at(:major, :minor, :patch, :state, :build).compact
        @segments = version.split('.').map{ |s| /\d+/ =~ s ? s.to_i : s }
      when Array
        version = version.join('.')
        @segments = version.split('.').map{ |s| /\d+/ =~ s ? s.to_i : s }
      when VersionNumber
        @segments = version.segments
      end
    end

    #
    def to_s
      @segments.join('.')
    end

    # This is here only becuase `File.join` calls it instead of #to_s.
    def to_str
      @segments.join('.')
    end

    #
    def inspect
      to_s
    end

    #
    def [](i)
      @segments.fetch(i,0)
    end

    # "Spaceship" comparsion operator.
    #
    # FIXME: Ensure it can handle state.
    def <=>( other )
      #other = other.to_t
      [@segments.size, other.size].max.times do |i|
        c = @segments[i] <=> other[i]
        return c if c != 0
      end
      0
    end

    # For pessimistic constraint (like '~>' in gems).
    #
    # FIXME: Ensure it can handle state.
    def =~( other )
      #other = other.to_t
      upver = other.dup
      upver[0] += 1
      @segments >= other and @segments < upver
    end

    # Major is the first number in the version series.
    def major
      @segments[0] || 0
    end

    # Minor is the second number in the version series.
    def minor
      @segments[1] || 0
    end

    # Patch is third number in the version series.
    def patch
      @segments[2] || 0
    end

    # The build number is everything after the patch number,
    # or for "oddly long" version numbers, anything from the
    # state position onward.
    def build
      i = @segments.index{ |s| STATES.include?(s) }
      if i
        b = @segments[i..-1].join('.')
      else
        b = @segments[3..-1].join('.')
      end
      b.empty? ? nil : b
    end

    # State is the version number segment that matches any entry
    # in the STATES constant.
    def state
      i = @segments.index{ |s| STATES.keys.include?(s) }
      @segments[i]
    end

    #
    def bump(which=:patch)
      case which.to_sym
      when :major
        v = [inc(major), 0, 0]
      when :minor
        v = [major, inc(minor), 0]
      when :patch
        v = [major, minor, inc(patch)]
      when :state
        if i = @segments.index{ |s| STATES.include?(s) }
          if n = inc(@segments[i])
            v = @segments[0...i] + [n] + (@segments[i+1] ? [1] : [])
          else
            v = @segments[0...i]
          end
        else
          v = @segments.dup
        end
      when :build
        if i = @segments.index{ |s| STATES.include?(s) }
          if i == @segments.size - 1
            v = @segments + [1]
          else
            v = @segments[0...-1] + [inc(@segments.last)]
          end
        else
          if @segments.size <= 3
            v = @segments + [1]
          else
            v = @segments[0...-1] + [inc(@segments.last)]
          end
        end
      when :last
        v = @segments[0...-1] + [inc(@segments.last)]
      else
        v = @segments.dup
      end
      self.class.new(v.compact)
    end

    # Change state.
    def restate(new_state)
      i = @segments.index{ |s| STATES.include?(s) }
      if i
        v = @segments[0...i] + [new_state.to_s] + [1]
      else
        v = @segments[0...3] + [new_state.to_s] + [1]
      end
      self.class.new(v)
    end

    #
    def each(&block)
      @segments.each(&block)
    end

    #
    def size
      @segments.size
    end

    ;; private

    # Segement incrementor.
    def inc(val)
      if i = STATES.index(val.to_s)
        STATES[i+1]
      else
        val.succ
      end
    end

    ;; public

    # Parses a string constraint returning the operation as a lambda.
    def self.constraint_lambda( constraint )
      op, val = *parse_constraint( constraint )
      lambda { |t| t.send(op, val) }
    end

    # Parses a string constraint returning the operator and value.
    def self.parse_constraint( constraint )
      constraint = constraint.strip
      re = %r{^(=~|~>|<=|>=|==|=|<|>)?\s*(\d+(:?[-.]\d+)*)$}
      if md = re.match( constraint )
        if op = md[1]
          op = '=~' if op == '~>'
          op = '==' if op == '='
          val = new( *md[2].split(/\W+/) )
        else
          op = '=='
          val = new( *constraint.split(/\W+/) )
        end
      else
        raise ArgumentError, "invalid constraint"
      end
      return op, val
    end

    ;; protected

    #
    attr :segments

  end

end

