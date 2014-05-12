# encoding: utf-8

require 'spec_helper'

describe Supervision do

  context "when used as instance" do
    before { Supervision.circuit_system.shutdown }

    it "permits options configuration" do
      supervision = Supervision.new { }
      supervision.configure do
        call_timeout 1.sec
        max_failures 10
      end
      expect(supervision.control.max_failures).to eql(10)
      expect(supervision.control.call_timeout).to eql(1.sec)
    end

    describe "#supervise" do
      it "supervises call" do
        called = []
        supervision = Supervision.supervise { |arg| called << "method_call_#{arg}"}
        supervision.call(:foo)
        expect(called).to match_array(['method_call_foo'])
      end

      it "accepts circuit options and exposes them" do
        supervision = Supervision.supervise(max_failures: 4,
                                            call_timeout: 0.1.sec,
                                            reset_timeout: 0.4.sec) { }
        expect(supervision.max_failures).to eq(4)
        expect(supervision.call_timeout).to eq(0.1.sec)
        expect(supervision.reset_timeout).to eq(0.4.sec)
      end
    end

    describe "#supervise_as" do
      it "registers named supervision" do
        called = []
        expect(Supervision[:danger]).to be_nil
        supervision = Supervision.supervise_as(:danger) { |arg|
          called << "method_call_#{arg}"
        }
        supervision.call(:foo)
        expect(Supervision[:danger]).to eql(supervision)
        expect(called).to match_array(['method_call_foo'])
      end

      it "accepts circuit options and exposes them" do
        Supervision.supervise_as(:danger, max_failures: 4,
                                          call_timeout: 0.1.sec,
                                          reset_timeout: 0.4.sec) { }
        expect(Supervision[:danger].max_failures).to eq(4)
        expect(Supervision[:danger].call_timeout).to eq(0.1.sec)
        expect(Supervision[:danger].reset_timeout).to eq(0.4.sec)
      end

      it "calls registered circuit by name" do
        called = []
        expect(Supervision[:danger]).to be_nil
        Supervision.supervise_as(:danger) { |arg| called << "method_call_#{arg}" }
        Supervision.danger(:foo)
        expect(called).to match_array(['method_call_foo'])
      end

      it "saves the name on circuit" do
        Supervision.supervise_as(:danger) { }
        circuit = Supervision[:danger]
        expect(circuit.name).to eql(:danger)
      end
    end

    describe "#circuit_system" do
      it "caches system circuits" do
        system = Supervision.circuit_system
        2.times { expect(Supervision.circuit_system).to eq(system) }
      end
    end

    describe "#configuration" do
      it "caches configuration" do
        config = Supervision.configuration
        2.times { expect(Supervision.configuration).to eq(config) }
      end
    end
  end

  context "when included as module" do
    before { Supervision.circuit_system.shutdown }

    class RemoteApi
      include Supervision

      def danger_call(state)
        state == :safe ? "hello" : raise(StandardError)
      end
      supervise_as(:danger, max_failures: 2) { |args| danger_call(args) }

      def wrapped_danger
        supervise { |args| danger_call(args) }
      end
    end

    it "allows to call registerd circuit" do
      api = RemoteApi.new
      api.danger
      api.danger
      expect { api.danger }.to raise_error(Supervision::CircuitBreakerOpenError)
    end
  end
end # Supervision
