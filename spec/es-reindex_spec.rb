require 'spec_helper'

describe ESReindex do
  let(:src)     { 'http://foo/bar_index' }
  let(:dst)     { 'http://biz/baz_index' }
  let(:options) { {update: true} }

  let(:reindexer) { ESReindex.new src, dst, options }

  it "can be freshly initialized with options" do
    expect(reindexer.options).to eq remove: false, update: true, frame: 1000, from_cli: false, copy_mappings: true
  end

  it "starts with 0 indexes done" do
    expect(reindexer.done).to eq 0
  end

  describe "#copy!" do
    after { reindexer.copy! }

    context "when run as a PORO" do

      it "doesn't use #exit" do
        reindexer.stub :clear_destination
        reindexer.stub :create_destination
        reindexer.stub :copy_docs
        reindexer.stub :check_docs
        expect(reindexer).not_to receive :exit
      end
    end

    context "when run from the CLI bin" do
      let(:options) { {from_cli: true} }

      it "exits 1 on failure" do
        reindexer.stub :confirm

        expect(reindexer).to receive(:clear_destination).and_return false
        expect(reindexer).to receive(:exit).with 1
      end

      it "exits 0 on success" do
        reindexer.stub :confirm

        expect(reindexer).to receive(:clear_destination).and_return true
        expect(reindexer).to receive(:create_destination).and_return true
        expect(reindexer).to receive(:copy_docs).and_return true
        expect(reindexer).to receive(:check_docs).and_return true
        expect(reindexer).to receive(:exit).with 0
      end
    end
  end

  skip "it can actually do stuff"
end
