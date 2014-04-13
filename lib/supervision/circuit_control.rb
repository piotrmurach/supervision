# encoding: utf-8

module Supervision
  # A class responsible for controling state of the circuit
  class CircuitControl
    extend Forwardable

    def_delegators :@config, :max_failures, :call_timeout, :failure_count

    attr_reader :config

    MAX_THREAD_LIFETIME = 5

    # Create a circuit control
    #
    # @param [Hash] options
    #
    # @api public
    def initialize(options = {})
      @config            = Configuration.new(options)
      @failure_count     = Atomic.new(0)
      @last_failure_time = Atomic.new
      @lock              = Mutex.new
      fsm
    end

    # Creates internal finite state machine to
    # transitions through three states :closed,
    # :open and :half_open.
    #
    # @return [FiniteMachine]
    #
    # @api private
    def fsm
      context = self
      @fsm ||= FiniteMachine.define do
        initial :closed

        target context

        events {
          event :trip,         [:closed, :half_open] => :open
          event :attempt_reset, :open => :half_open
          event :reset,         :half_open => :closed
        }

        callbacks {
          on_enter :closed do |event|
            reset_failure
          end

          on_enter :open do |event|
            measure_timeout
            fail_fast!
          end

          on_enter :half_open do |event|
          end
        }
      end
    end

    def_delegators :@fsm, :trip, :attempt_reset, :reset, :current

    # Total failure count for current circuit
    #
    # @return [Integer]
    #
    # @api public
    def failure_count
      @failure_count.value
    end

    # Last time failure occured
    #
    # @return [Time]
    #
    # @api public
    def last_failure_time
      @last_failure_time.value
    end

    # Fail fast on any call
    #
    # @raise [CircuitBreakerOpenError]
    #
    # @api private
    def fail_fast!
      # monitor.record_open
      raise CircuitBreakerOpenError
    end

    # @return [Boolean]
    #
    # @api private
    def failure_count_exceeded?
      failure_count > @config.max_failures
    end

    # @return [Boolean]
    #
    # @api private
    def tripped?
      fsm.open? && timeout_exceeded?
    end

    # Check if remaining duration until reset has been exceeded
    #
    # @return [Boolean]
    #   whether or not the breaker will attempt a reset by transitioning
    #   to :half_open state
    #
    # @api private
    def timeout_exceeded?
      return false unless last_failure_time
      timeout = Time.now - last_failure_time
      timeout > @config.reset_timeout
    end

    # Handler exception
    #
    # @api public
    def handle(error = nil)
      fail_fast! if fsm.open?
      record_failure
      trip if failure_count_exceeded? || fsm.half_open?
    end

    def record_success
      reset if fsm.half_open?
      reset_failure
    end

    # Records failure count
    #
    # @api public
    def record_failure
      if fsm.closed? || fsm.half_open?
        @failure_count.update { |v| v + 1 }
        @last_failure_time.value = Time.now
      end
    end

    # Resets failure count
    #
    # @api public
    def reset_failure
      @failure_count.value = 0
      @last_failure_time.value = nil
    end

    # Measure remaining timeout
    #
    # @api private
    def measure_timeout
      Thread.new do
        Thread.current.abort_on_exception = true
        thread = Thread.current
        thread[:created_at] = Time.now
        @lock.synchronize do
          loop do
            if tripped?
              attempt_reset
              break
            elsif Time.now - thread[:created_at] > max_thread_lifetime
              thread.kill
            end
          end
        end
      end
    end

    # Estimate maximum duration the scheduling thread should live
    #
    # @return [Time]
    #
    # @api private
    def max_thread_lifetime
      @config.reset_timeout + 100.milli
    end
  end # CircuitControl
end # Supervision
