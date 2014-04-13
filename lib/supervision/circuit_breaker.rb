# encoding: utf-8

module Supervision
  # A class responsible for protecting remote calls
  class CircuitBreaker
    include Timeout

    attr_reader :control

    def initialize(options = {}, &block)
      if block.nil?
        raise ArgumentError, 'CircuitBreaker.new requires a block'
      end
      @control = CircuitControl.new(options)
      @circuit = Atomic.new(block)
      @mutex   = Mutex.new
      @before_hook  = -> {}
      @success_hook = -> {}
      @failure_hook = -> {}
    end

    # Configure circuit instance parameters
    #
    # @yield [Configuration]
    #
    # @api public
    def configure(&block)
      if block.arity.zero?
        control.config.instance_eval(&block)
      else
        yield control.config
      end
    end

    # Executes the dangerous call
    #
    # # TODO: this should distribute calls so we don't wait
    #  in sync call for timeout
    #
    # @api public
    def call(*args)
      @before_hook.call
      begin
        result = dispatch(*args)
        @success_hook.call
        result
      rescue Exception => error
        control.handle(error)
        @failure_hook.call
      end
    end

    def force_open
    end

    def force_close
    end

    def before(&block)
      @before_hook = block
    end

    # Callback executed on successful call
    #
    # @api public
    def on_success(&block)
      @success_hook = block
    end
    alias_method :on_closed, :on_success

    def on_failure(&block)
      @failure_hook = block
    end
    alias_method :on_open, :on_failure

    private

    # Dispatch message to the current circuit
    #
    # @api private
    def dispatch(*args)
      result = timeout(control.call_timeout) do
        @circuit.value.call(*args)
      end
      control.record_success
      result
    end
  end # CircuitBreaker
end # Supervision
