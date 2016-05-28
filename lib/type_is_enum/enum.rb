# A Ruby implementation of Joshua Bloch's
# [typesafe enum pattern](http://www.oracle.com/technetwork/java/page1-139488.html#replaceenums)
module TypeIsEnum
  # Base class for typesafe enum classes.
  class Enum
    include Comparable

    class << self

      # Returns an array of the enum instances in declaration order
      # @return [Array<self>] All instances of this enum, in declaration order
      def to_a
        as_array.dup
      end

      # Returns the number of enum instances
      # @return [Integer] the number of instances
      def size
        as_array ? as_array.length : 0
      end

      # Iterates over the set of enum instances
      # @yield [self] Each instance of this enum, in declaration order
      # @return [Array<self>] All instances of this enum, in declaration order
      def each(&block)
        to_a.each(&block)
      end

      # Iterates over the set of enum instances
      # @yield [self, Integer] Each instance of this enum, in declaration order,
      #   with its ordinal index
      # @return [Array<self>] All instances of this enum, in declaration order
      def each_with_index(&block)
        to_a.each_with_index(&block)
      end

      # Iterates over the set of enum instances
      # @yield [self] Each instance of this enum, in declaration order
      # @return [Array] An array containing the result of applying `&block`
      #   to each instance of this enum, in instance declaration order
      def map(&block)
        to_a.map(&block)
      end

      # Looks up an enum instance based on its key
      # @param key [Symbol] the key to look up
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_key(key)
        by_key[key]
      end

      # Looks up an enum instance based on its ordinal
      # @param ord [Integer] the ordinal to look up
      # @return [self, nil] the corresponding enum instance, or nil
      def find_by_ord(ord)
        return nil if ord < 0 || ord > size
        as_array[ord]
      end

      private

      def add(key, *args, &block)
        fail TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
        obj = new(*args)
        obj.instance_variable_set :@key, key
        obj.instance_variable_set :@ord, size
        self.class_exec(obj) do |instance|
          register(instance)
          instance.instance_eval(&block) if block_given?
        end
      end

      def by_key
        @by_key ||= {}
      end

      def as_array
        @as_array ||= []
      end

      def valid_key(instance)
        key = instance.key
        if (found = find_by_key(key))
          warn("ignoring redeclaration of #{name}::#{key} (source: #{caller[4]})")
          nil
        else
          key
        end
      end

      def register(instance)
        key = valid_key(instance)
        return unless key

        const_set(key.to_s, instance)
        by_key[key] = instance
        as_array << instance
      end
    end

    # The symbol key for the enum instance
    # @return [Symbol] the key
    attr_reader :key

    # The ordinal of the enum instance, in declaration order
    # @return [Integer] the ordinal
    attr_reader :ord

    # Compares two instances of the same enum class based on their declaration order
    # @param other [self] the enum instance to compare
    # @return [Integer, nil] -1 if this value precedes `other`; 0 if the two are
    #   the same enum instance; 1 if this value follows `other`; `nil` if `other`
    #   is not an instance of this enum class
    def <=>(other)
      ord <=> other.ord if self.class == other.class
    end

    # Generates a Fixnum hash value for this enum instance
    # @return [Fixnum] the hash value
    def hash
      @hash ||= begin
        result = 17
        result = 31 * result + self.class.hash
        result = 31 * result + ord
        result.is_a?(Fixnum) ? result : result.hash
      end
    end

    def to_s
      "#{self.class}::#{key} [#{ord}]"
    end
  end
end
