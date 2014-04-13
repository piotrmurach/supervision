# encoding: utf-8

module Supervision
  # A mixin to define time related helpers
  module TimeDSL
    def millisecond
      self / 1000.0
    end
    alias_method :milliseconds, :millisecond
    alias_method :milli       , :millisecond
    alias_method :millis      , :millisecond

    def second
      self * 1
    end
    alias_method :seconds, :second
    alias_method :sec    , :second
    alias_method :secs   , :second

    def minute
      self * 60
    end
    alias_method :minutes, :minute
    alias_method :min    , :minute
    alias_method :mins   , :minute

    def hour
      self * 3600
    end
    alias_method :hours, :hour
  end # TimeDSL
end # Supervision

unless Numeric.method_defined?(:second)
  Numeric.send(:include, Supervision::TimeDSL)
end
