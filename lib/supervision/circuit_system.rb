# encoding: utf-8

module Supervision
  # A class responsible for registering circuits
  class CircuitSystem
    extend Forwardable

    def_delegators '@registry', :[], :get, :[]=, :set,
                   :register, :delete, :unregister

    def initialize
      @registry = Registry.new
    end

  end # CircuitSystem
end # Supervision
