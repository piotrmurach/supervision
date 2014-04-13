# encoding: utf-8

require 'spec_helper'

describe Supervision::Configuration do

  subject(:config) { described_class.new }

  it { expect(config.max_failures).to eql(5) }

  it { expect(config.call_timeout).to eql(0.01) }

  it { expect(config.reset_timeout).to eql(0.1) }
end
