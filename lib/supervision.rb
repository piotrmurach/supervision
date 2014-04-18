# encoding: utf-8

require "thread"
require "timeout"
require "finite_machine"

require "supervision/version"
require "supervision/atomic"
require "supervision/time_dsl"
require "supervision/configuration"
require "supervision/registry"
require "supervision/circuit_control"
require "supervision/circuit_breaker"
require "supervision/circuit_system"
require "supervision/circuit_monitor"

module Supervision
  # Generic error
  SupervisionError = Class.new(::StandardError)

  # Raised when circuit opens
  CircuitBreakerOpenError = Class.new(SupervisionError)

  TypeError = Class.new(SupervisionError)

  class << self
    def included(base)
      base.send :extend, ClassMethods
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Initialize a circuit system
    #
    # @api private
    def init
      @circuit_system = CircuitSystem.new
    end

    def circuit_system
      Thread.current[:supervision_circuit_system] ||= @circuit_system
    end

    # Create a new circuit breaker
    #
    # @api public
    def new(name = nil, options = {}, &block)
      name ? supervise_as(name, options, &block) : supervise(options, &block)
    end

    # Retrieve circuit by name
    #
    # @api public
    def [](name)
      Supervision.circuit_system[name]
    end
  end

  module ClassMethods
    def supervise(options = {}, &block)
      CircuitBreaker.new(options, &block)
    end

    def supervise_as(name, options = {}, &block)
      circuit = supervise(options, &block)
      Supervision.circuit_system[name] = circuit
      send(:define_method, name) { |*args| circuit.call(args) }
      circuit
    end
  end

  extend ClassMethods
end # Supervision

Supervision.init
