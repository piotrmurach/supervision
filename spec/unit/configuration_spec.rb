# encoding: utf-8

require 'spec_helper'

describe Supervision::Configuration do
  let(:object) { described_class }

  subject(:config) { described_class.new }

  it "fails fast with unknown config option" do
    expect {
      object.new max_fail: 2
    }.to raise_error(Supervision::InvalidParameterError)
  end

  context 'when default' do
    it { expect(config.max_failures).to eql(5) }

    it { expect(config.call_timeout).to eql(0.01) }

    it { expect(config.reset_timeout).to eql(0.1) }
  end

  context 'when setting' do
    it "sets maximum failures" do
      config.max_failures(3)
      expect(config.max_failures).to eq(3)
    end

    it "sets call timeout" do
      config.call_timeout(1.sec)
      expect(config.call_timeout).to eq(1.sec)
    end

    it "sets reset timeout" do
      config.reset_timeout(10.sec)
      expect(config.reset_timeout).to eq(10.sec)
    end
  end
end
