# encoding: utf-8

module Supervision
  # A class responsible for recording circuit performance
  class CircuitMonitor

    attr_reader :times_opened

    # Timestamp for the last circuit open state
    #
    # @api public
    attr_reader :last_opened

    def initialize
      @total_failed_calls  = Counter.new
      @total_success_calls = Counter.new
      @total_calls         = Counter.new
      @state_transitions   = Counter.new
    end

    def total_calls
      @total_calls.value
    end

    def total_success_calls
      @total_success_calls.value
    end

    def total_failed_calls
      @total_failed_calls.value
    end

    def record_success
      @total_success_calls.increment
      @total_calls.increment
    end

    def record_failure
      @total_failed_calls.increment
      @total_calls.increment
    end

    def measure(type)

    end

    # Reset the circuit statistics
    #
    # @return [nil]
    #
    # @api public
    def reset
      total_calls.clear
      total_success_calls.clear
      total_failed_calls.clear
    end
  end # CircuitMonitor
end # Supervision
