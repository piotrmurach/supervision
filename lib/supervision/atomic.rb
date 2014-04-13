# encoding: utf-8

module Supervision
  # A class responsible for creating threadsafe value objects
  class Atomic

    # Initialize an Atomic instance
    #
    # @param [Numeric] value
    #
    # @api public
    def initialize(value = nil)
      @mutex = Mutex.new
      @value = value
    end

    # Retrieve value
    #
    # @api public
    def get
      @mutex.synchronize { @value }
    end
    alias_method :value, :get

    # Set value
    #
    # @api public
    def set(new_value)
      @mutex.synchronize { @value = new_value}
    end
    alias_method :value=, :set

    # Update value
    #
    # @api public
    def update
      set(new_value = yield(get)) if block_given?
      new_value
    end
  end # Atomic
end # Supervision
