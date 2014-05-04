# encoding: utf-8

require 'spec_helper'

describe Supervision::Configuration do
  let(:object) { described_class }

  subject(:config) { described_class.new }

  it { expect(config.max_failures).to eql(5) }

  it { expect(config.call_timeout).to eql(0.01) }

  it { expect(config.reset_timeout).to eql(0.1) }

  it "fails fast with unknown config option" do
    expect {
      object.new max_fail: 2
    }.to raise_error(Supervision::InvalidParameterError)
  end
end
