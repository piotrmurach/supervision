# encoding: utf-8

require 'spec_helper'

describe Supervision::Counter do

  let(:object) { described_class }

  subject(:counter) { object.new }

  it "initializes to 0" do
    expect(counter.value).to eq(0)
  end

  it "increments default value" do
    counter.increment
    expect(counter.value).to eq(1)
  end

  it "increments by value" do
    counter.increment(10)
    expect(counter.value).to eq(10)
  end

  it "increments in threads" do
    spawn(10) { counter.increment }
    expect(counter.value).to eq(10)
  end

  it "increments in threads by value" do
    spawn(10) { counter.increment(10) }
    expect(counter.value).to eq(100)
  end
end
