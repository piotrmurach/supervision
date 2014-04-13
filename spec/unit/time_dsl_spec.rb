# encoding: utf-8

require 'spec_helper'

describe Supervision::TimeDSL do
  it "defines millisecond/milliseconds/milli/millis" do
    expect(1.millisecond).to eql(0.001)
    expect(1.milli).to eql(0.001)
    expect(10.milliseconds).to eql(0.01)
    expect(10.millis).to eql(0.01)
  end

  it "defines second/seconds" do
    expect(1.second).to eql(1)
    expect(10.seconds).to eql(10)
    expect(1.sec).to eql(1)
    expect(10.secs).to eql(10)
  end

  it "defines minute/minutes" do
    expect(1.minute).to eql(60)
    expect(10.minutes).to eql(600)
    expect(1.min).to eql(60)
    expect(10.mins).to eql(600)
  end

  it "defines hours/hours" do
    expect(1.hour).to eql(3600)
    expect(2.hours).to eql(7200)
  end
end
