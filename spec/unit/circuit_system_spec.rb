# encoding: utf-8

require "spec_helper"

describe Supervision::CircuitSystem do
  let(:object) { described_class }

  let(:circuit) { Supervision.supervise { } }

  subject(:system) { object.new }

  it { expect(system).to respond_to(:register) }

  it { expect(system).to respond_to(:delete) }

  it { expect(system).to respond_to(:registered?) }

  it { expect(system).to respond_to(:empty?) }

  it { expect(system).to respond_to(:names) }

  describe "#shutdown" do
    it "shuts down system" do
      expect(system.registry).to receive(:clear)
      system.shutdown
    end
  end

  describe "#to_s" do
    it 'prints object info' do
      system.register(:danger, circuit)
      expect(system.to_s).to include("@names=[:danger]")
    end
  end

  describe "#inspect" do
    it 'prints object info' do
      system.register(:danger, circuit)
      expect(system.inspect).to include("@names=[:danger]")
    end
  end
end
