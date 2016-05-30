class Factory
  def self.new(*attrs, &block)
    raise ArgumentError, "wrong number of arguments (0 for 1+)" if attrs.length == 0
    name = attrs.shift if attrs.first.is_a? String
    raise NameError, "identifier #{name} needs to be constant" if name[0][/[A-Z]/] == nil
    clas = Class.new do
      attr_accessor(*attrs)

      define_method :members do
        attrs
      end

      def initialize(*args)
        raise ArgumentError, "struct size differs" unless args.length == length
        members.zip(args) { |atr, arg| 
          send "#{atr}=", arg
        }
      end

      def == other
        self.class == other.class
      end

      def [] atr
        atr = members[atr] if atr.is_a? Fixnum
        send atr
      end

      def []= atr, value
        send "#{atr}=", value
      end

      def inspect
        "class #{self.class} with members: #{members.join(", ")}"
      end

      def each
        members.each { |atr|
          yield self[atr]
        }
      end

      def each_pair
        members.each { |atr|
          yield atr, self[atr]
        }
      end

      def length
        members.length
      end

      def select &block
        members.map{ |atr| self[atr]}.select(&block)
      end

      def to_a
        members.map{ |atr| self[atr]}
      end

      def to_h
        members.map{ |atr| [atr, self[atr]]}.to_h
      end

      def values_at(*nums)
        nums.map{ |num| values[num]}
      end

      alias :eql? :==
      alias :size :length
      alias :values :to_a
      alias :to_s :inspect

      self.class_eval(&block) if block_given?

    end

    const_set(name, clas) if name
    clas
  end
end