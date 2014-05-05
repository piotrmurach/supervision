# encoding: utf-8

module Supervision
  # A class responsible for protecting remote calls
  class CircuitBreaker
    include Timeout

    attr_reader :control

    attr_reader :name

    # Create a CircuitBreaker
    #
    # @example
    #   circuit = CircuitBreaker { ... }
    #
    # @api public
    def initialize(options = {}, &block)
      if block.nil?
        raise InvalidParameterError, 'CircuitBreaker.new requires a block'
      end
      @name    = options.delete(:name)
      @control = CircuitControl.new(options)
      @circuit = Atomic.new(block)
      @mutex   = Mutex.new
    end

    # Configure circuit instance parameters
    #
    # @yield [Configuration]
    #
    # @api public
    def configure(&block)
      control.config.configure(&block)
    end

    # Executes the dangerous call
    #
    # # TODO: this should distribute calls so we don't wait
    #  in sync call for timeout
    #
    # @api public
    def call(*args)
      handle_before
      begin
        result = dispatch(*args)
        handle_success
        result
      rescue Exception => error
        handle_failure(error)
      end
    end

    # Reset this circuit to closed state
    #
    # @example
    #   supervision.reset!
    #
    # @return [nil]
    #
    # @api public
    def reset!
      control.reset!
    end

    # Define before handler
    #
    # @api public
    def before(&block)
      @before = block
      self
    end

    # Define success handler
    #
    # @return [Supervision::CircuitBreaker]
    #
    # @api public
    def on_success(&block)
      @on_success = block
      self
    end
    alias_method :on_closed, :on_success

    # Define failure handler
    #
    # @return [Supervision::CircuitBreaker]
    #
    # @api public
    def on_failure(&block)
      @on_failure = block
      self
    end
    alias_method :on_open, :on_failure

    # Detailed string representation of this circuit
    #
    # @return [String]
    #
    # @api public
    def inspect
      "#<#{self.class.name}:#{object_id} @name=#{name}>"
    end

    # Detailed string representation of this circuit
    #
    # @return [String]
    #
    # @api public
    def to_s
      "#<#{self.class.name}:#{object_id} @name=#{name}>"
    end

    private

    # Invoke before handler
    #
    # @api private
    def handle_before
      @before.call if @before
    end

    # Invoke success handler
    #
    # @api private
    def handle_success
      @on_success.call if @on_success
    end

    # Invoke failure handler and instrument circuit controller
    #
    # @api private
    def handle_failure(error)
      control.handle(error)
      @on_failure.call(error) if @on_failure
    end

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
