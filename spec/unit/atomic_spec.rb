# encoding: utf-8

require 'spec_helper'

RSpec.describe Supervision::Atomic do

  let(:object) { described_class }

  it "sets the value to nil" do
    atomic = object.new
    expect(atomic.value).to eql(nil)
  end

  it "sets the value" do
    atomic = object.new(1)
    expect(atomic.value).to eql(1)
  end

  it "set value" do
    atomic = object.new
    atomic.value = 1000
    expect(atomic.value).to eql(1000)
  end

  it "updates current value" do
    atomic = object.new(1000)
    new_value = atomic.update { |v| v + 1 }
    expect(new_value).to eql(1001)
  end
end
