require 'spec_helper'

describe Supervision::Registry do

  let(:circuit) { Supervision.supervise { } }

  subject(:registry) { described_class.new }

  it "registers" do
    registry[:danger] = circuit
    expect(registry[:danger]).to eql(circuit)
  end

  it "refuses to add non circuit object" do
    expect {
      registry[:danger] = Object.new
    }.to raise_error(Supervision::TypeError)
  end

  it "" do
    registry[:danger] = circuit
    expect(registry.names).to eql([:danger])
  end

  it "" do
    registry[:danger] = circuit
    registry.delete(:danger)
    expect(registry.names).to be_empty
  end
end
