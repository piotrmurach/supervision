# encoding: utf-8

require 'spec_helper'

describe Supervision::CircuitControl do
  let(:object) { described_class }

  let(:max_failures) { 1 }

  let(:reset_timeout) { 0.1.sec }

  subject(:control) {
    object.new max_failures: max_failures,
               reset_timeout: reset_timeout
  }

  context 'when closed' do
    it "resets the failure count on success" do
      expect(control.failure_count).to eql(0)
      expect(control.fsm.current).to eql(:closed)
      control.record_failure
      expect(control.failure_count).to eql(1)
      control.reset_failure
      expect(control.failure_count).to eql(0)
      expect(control.fsm.current).to eql(:closed)
    end

    it "increments failure count on exceptions and trips the wire" do
      expect(control.failure_count).to eql(0)
      expect(control.fsm.current).to eql(:closed)

      control.handle
      expect(control.failure_count).to eql(1)
      expect(control.fsm.current).to eql(:closed)

      expect{ control.handle }.to raise_error(Supervision::CircuitBreakerOpenError)
      expect(control.failure_count).to eql(2)
      expect(control.fsm.current).to eql(:open)
    end
  end

  context 'when open' do
    it "fails all calls fast with CircuitBreakerOpenError" do
      control.fsm.state = :open
      expect { control.handle }.to raise_error(Supervision::CircuitBreakerOpenError)
      expect(control.fsm.current).to eql(:open)
    end

    it "enters :half_open state after the configured :reset_timeout" do
      control.record_failure
      expect{ control.handle }.to raise_error(Supervision::CircuitBreakerOpenError)
      sleep 0.2
      expect(control.fsm.current).to eql(:half_open)
    end
  end

  context 'when half open' do
    before { control.fsm.state = :half_open }

    it "resets the breaker back to :closed state on successful call" do
      control.record_success
      expect(control.fsm.current).to eql(:closed)
      expect(control.failure_count).to eql(0)
    end

    it "trips the breaker back to :open state on failed call" do
      expect { control.handle }.to raise_error(Supervision::CircuitBreakerOpenError)
      expect(control.failure_count).to eql(1)
      expect(control.fsm.current).to eql(:open)
    end
  end
end
