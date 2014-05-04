# encoding: utf-8

require "spec_helper"

describe Supervision::CircuitSystem do
  let(:object) { described_class }

  subject(:system) { object.new }

  it { expect(system).to respond_to(:register) }

  it { expect(system).to respond_to(:delete) }

  it { expect(system).to respond_to(:registered?) }

  it { expect(system).to respond_to(:empty?) }

  it { expect(system).to respond_to(:names) }

  it "shuts down system" do
    expect(system.registry).to receive(:clear)
    system.shutdown
  end
end
