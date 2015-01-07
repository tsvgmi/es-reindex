require 'spec_helper'

describe ESReindex do
  let(:src)     { 'http://foo/bar_index' }
  let(:dst)     { 'http://biz/baz_index' }
  let(:options) { {update: true} }

  let(:reindexer) { ESReindex.new src, dst, options }

  it "can be freshly initialized with options" do
    expect(reindexer.options).to eq remove: false, update: true, frame: 1000
  end

  it "starts with 0 indexes done" do
    expect(reindexer.done).to eq 0
  end

  skip "it can actually do stuff"
end
