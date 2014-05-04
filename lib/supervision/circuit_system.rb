# encoding: utf-8

module Supervision
  # A class responsible for registering circuits
  class CircuitSystem
    extend Forwardable

    attr_reader :registry

    def_delegators '@registry', :[], :get, :[]=, :set, :register, :delete,
                   :unregister, :names, :empty?, :registered?

    # Create a CircuitSystem
    #
    # @api public
    def initialize
      @registry = Registry.new
    end

    # Shutdown this circuit system
    #
    # @api public
    def shutdown
      @registry.clear
    end

    # Detailed string representation of this circuit system
    #
    # @return [String]
    #
    # @api public
    def inspect
      "#<#{self.class.name}:#{object_id}> @names=#{names}>"
    end

    # Detailed string representation of this circuit system
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class.name}:#{object_id}> @names=#{names}>"
    end
  end # CircuitSystem
end # Supervision
