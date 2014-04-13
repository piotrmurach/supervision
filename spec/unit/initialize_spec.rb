# encoding: utf-8

require 'spec_helper'

describe Supervision do

  context "when used as instance" do
    it "permits options configuration" do
      supervision = Supervision.new { }
      supervision.configure do
        call_timeout 1.sec
        max_failures 10
      end
      expect(supervision.control.max_failures).to eql(10)
      expect(supervision.control.call_timeout).to eql(1.sec)
    end

    it "allows to supervise call" do
      called = []
      supervision = Supervision.supervise { called << 'method_call'}
      supervision.call
      expect(called).to eql(['method_call'])
    end

    it "registers named supervision" do
      called = []
      supervision = Supervision.supervise_as(:danger) { called << 'method_call'}
      supervision.call
      expect(called).to eql(['method_call'])
      expect(Supervision.circuit_system[:danger]).to eql(supervision)
    end
  end

  context "when included as module" do
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
