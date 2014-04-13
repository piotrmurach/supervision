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
    # @api public
    def []=(name, circuit)
      unless circuit.is_a?(CircuitBreaker)
        raise TypeError, 'not a circuit'
      end
      @lock.synchronize do
        @map[name.to_sym] = circuit
      end
    end

    # Retrieve a circuit by name
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
    # @api public
    def registered?(name)
      names.include?(name)
    end

    def names
      @lock.synchronize { @map.keys }
    end

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
