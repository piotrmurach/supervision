# encoding: utf-8

require 'spec_helper'

describe Supervision::CircuitBreaker do

  let(:dangerous_call_timeout) { sleep 1 }

  let(:dangerous_call_error) { raise StandardError }

  let(:safe_call) { 'value' }

  let(:object) { described_class }

  context 'when closed' do
    it "successfully calls the method" do
      circuit = object.new call_timeout: 1.milli do |arg|
        arg == :danger ? dangerouse_call_error : safe_call
      end
      expect(circuit.call(:safe)).to eql(safe_call)
    end

    it "increments a failure counter for exceptions" do
      circuit = object.new call_timeout: 1.milli do
        arg == :danger ? dangerouse_call_error : safe_call
      end
      circuit.call(:danger)
      expect(circuit.control.failure_count).to eql(1)
    end

    it "increments a failure counter for calls exceeding :call_timeout" do
      circuit = object.new call_timeout: 1.milli do
        dangerous_call_timeout
      end
      circuit.call
      expect(circuit.control.failure_count).to eql(1)
    end
  end

  context 'when open' do
    it "fails all calls with a CircuitBreakerOpenError" do
      circuit = object.new max_failures: 2, reset_timeout: 1.sec do
        dangerous_call_error
      end
      circuit.call
      circuit.call
      expect { circuit.call }.to raise_error(Supervision::CircuitBreakerOpenError)
    end

    it "enters a :half_open state after the :reset_timeout" do
      circuit = object.new reset_timeout: 0.1.sec, max_failures: 0 do
        dangerous_call_error
      end
      expect { circuit.call }.to raise_error(Supervision::CircuitBreakerOpenError)
      expect(circuit.control.current).to eq(:open)
      sleep 0.2
      expect(circuit.control.current).to eq(:half_open)
    end
  end

  context 'when half open' do
    it "resets the breaker back to :closed state on successful call" do
      circuit = object.new reset_timeout: 100.milli, max_failures: 0 do |arg|
        arg == :danger ? dangerous_call_error : safe_call
      end
      expect {
        circuit.call(:danger)
      }.to raise_error(Supervision::CircuitBreakerOpenError)
      expect(circuit.control.current).to eql(:open)
      sleep 0.2
      expect(circuit.control.current).to eql(:half_open)
      circuit.call(:safe)
      expect(circuit.control.current).to eql(:closed)
    end
  end

  context 'when with callback' do
    it "notifies about successful call" do
      callbacks = []
      circuit = object.new do safe_call end
      circuit.on_success { callbacks << 'on_success' }
      circuit.call
      expect(callbacks).to eql(["on_success"])
    end

    it "notifies about failed call" do
      callbacks = []
      circuit = object.new do dangerous_call_error end
      circuit.on_failure { callbacks << 'on_failure'}
      circuit.before { callbacks << 'before'}
      circuit.call
      expect(callbacks).to eql(['before', 'on_failure'])
    end
  end

  it "fails fast with unknown config option" do
    expect {
      object.new max_fail: 2 do safe_call end
    }.to raise_error(ArgumentError)
  end
end
