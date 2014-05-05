# encoding: utf-8

require "spec_helper"

describe Supervision::CircuitMonitor do
  let(:object) { described_class }

  subject(:monitor) { object.new }

  describe "#record_success" do
    it "records success" do
      monitor.record_success
      expect(monitor.total_success_calls).to eq(1)
      expect(monitor.total_failed_calls).to eq(0)
      expect(monitor.total_calls).to eq(1)
    end
  end

  describe "#record_failure" do
    it "records failure" do
      monitor.record_failure
      expect(monitor.total_success_calls).to eq(0)
      expect(monitor.total_failed_calls).to eq(1)
      expect(monitor.total_calls).to eq(1)
    end
  end
end
