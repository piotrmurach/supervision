# encoding: utf-8

module Supervision
  # A class responsible for registering/unregistering circuits
  class Registry
    # Initialize a Registry
    #
    # @api public
    def initialize
      @lock = Mutex.new
      @map = {}
    end

    # Register a circuit
    #
    # @param [String] name
    #   the name under which to register
    #
    # @param [Supervision::CircuitBreaker] circuit
    #   the registered circuit breaker
    #
    # @api public
    def []=(name, circuit)
      unless circuit.is_a?(CircuitBreaker)
        raise TypeError, 'not a type of circuit breaker'
      end
      if registered?(name)
        raise DuplicateEntryError, "`#{name}` is already registered"
      end
      @lock.synchronize do
        @map[name.to_sym] = circuit
      end
    end

    # Retrieve a circuit by name
    #
    # @param [String] name
    #
    # @api public
    def [](name)
      @lock.synchronize do
        @map[name.to_sym]
      end
    end

    # Remove from registry
    #
    # @api public
    def delete(name)
      @lock.synchronize do
        @map.delete name.to_sym
      end
    end

    alias_method :register,   :[]=
    alias_method :get,        :[]
    alias_method :unregister, :delete

    # Check if circuit is in registry
    #
    # @return [Boolean]
    #
    # @api public
    def registered?(name)
      names.include?(name) || names.include?(name.to_sym)
    end

    # Retrieve registered circuits' names
    #
    # @return [Array]
    #
    # @api public
    def names
      @lock.synchronize { @map.keys }
    end

    # Check if registry is empty or not
    #
    # @return [Boolean]
    #
    # @api public
    def empty?
      @lock.synchronize { @map.empty? }
    end

    # Remove all registered circuits
    #
    # @example
    #  registry.clear
    #
    # @return [Hash]
    #
    # @api public
    def clear
      hash = nil
      @lock.synchronize do
        hash = @map.dup
        @map.clear
      end
      hash
    end
  end # Registry
end # Supervision
