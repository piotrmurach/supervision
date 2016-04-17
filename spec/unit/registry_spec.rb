# encoding: utf-8

require 'spec_helper'

RSpec.describe Supervision::Registry do

  let(:circuit) { Supervision.supervise { } }

  subject(:registry) { described_class.new }

  it "registers a circuit" do
    registry[:danger] = circuit
    expect(registry[:danger]).to eql(circuit)
  end

  it "refuses to add non circuit object" do
    expect {
      registry[:danger] = Object.new
    }.to raise_error(Supervision::TypeError)
  end

  it "refuses to add duplicate entry" do
    registry[:danger] = circuit
    expect {
      registry[:danger] = circuit
    }.to raise_error(Supervision::DuplicateEntryError)
  end

  it "returns nil for unregistered circuit" do
    expect(registry[:danger]).to be_nil
  end

  it "gets a circuit by name" do
    registry.register :danger, circuit
    expect(registry[:danger]).to eq(circuit)
  end

  it "retrieves registered circuit names" do
    registry.register :danger, circuit
    registry.register :fragile, circuit
    expect(registry.names).to match_array([:danger, :fragile])
  end

  it "deletes circuit from registry" do
    registry.register :danger, circuit
    registry.delete :danger
    expect(registry.empty?).to eq(true)
  end

  it "checks if circuit is registered" do
    registry.register :danger, circuit
    expect(registry.registered?(:danger)).to eq(true)
  end

  it "clears all circuits" do
    registry.register :danger, circuit
    expect(registry.empty?).to eq(false)
    registry.clear
    expect(registry.empty?).to eq(true)
  end
end
