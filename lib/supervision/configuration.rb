# encoding: utf-8

module Supervision
  # A class responsbile for the circuit configuration options
  class Configuration
    DEFAULT_MAX_FAILURES = 5

    DEFAULT_CALL_TIMEOUT = 10.milli

    DEFAULT_RESET_TIMEOUT = 100.milli

    # Create a Configuration options
    #
    # @api public
    def initialize(options = {})
      verify_options!(options)
      @max_failures = Atomic.new(options.fetch(:max_failures,
                                               DEFAULT_MAX_FAILURES))
      @call_timeout = Atomic.new(options.fetch(:call_timeout,
                                               DEFAULT_CALL_TIMEOUT))
      @reset_timeout = Atomic.new(options.fetch(:reset_timeout,
                                                DEFAULT_RESET_TIMEOUT))
    end

    def max_failures=(value)
      @max_failures.set(value)
    end

    def max_failures(number = nil)
      return @max_failures.value unless number

      self.max_failures = number
    end

    def call_timeout=(value)
      @call_timeout.set(value)
    end

    def call_timeout(time = nil)
      return @call_timeout.value unless time

      self.call_timeout = time
    end

    def reset_timeout=(value)
      @reset_timeout.set(value)
    end

    def reset_timeout(time = nil)
      return @reset_timeout.value unless time

      self.reset_timeout = time
    end

    private

    def known_options
      [:max_failures, :call_timeout, :reset_timeout]
    end

    def verify_options!(options)
      options.keys.each do |key|
        raise_unknown_config_option(key) unless known_options.include?(key)
      end
    end

    def raise_unknown_config_option(option)
      raise InvalidParameterError,
            "`#{option}` isn`t recognized as valid parameter." \
            " Please use one of `#{known_options.join(', ')}`"
    end
  end # Configuration
end # Supervision
