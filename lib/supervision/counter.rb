# encoding: utf-8

module Supervision
  # A class responsible for measuring increments/decrements of value
  class Counter
    # Create a Counter
    #
    # @api public
    def initialize
      @count = Atomic.new(0)
    end

    # Reset the counter
    #
    # @return [nil]
    #
    # @api public
    def clear
      @count.set(0)
    end

    # Increment counter
    #
    # @return [nil]
    #
    # @api public
    def increment(incr = 1)
      @count.update { |v| v + incr }
    end

    # Decrement counter
    #
    # @param []
    #
    # @return [nil]
    #
    # @api public
    def decrement(decr = 1)
      @count.update { |v| v + decr }
    end

    # Return the value
    #
    # @api public
    def value
      @count.value
    end
  end # Counter
end # Supervision
