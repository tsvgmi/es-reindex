require 'spec_helper'

describe "copy!", type: :integration do
  let(:orig_index_name)  { "test_index" }
  let(:new_index_name)   { "test_index_clone" }
  let(:orig_index_alias) { "test_index_alias" }

  let!(:original_klass)  { test_klass index_name: orig_index_name }
  let!(:new_klass)       { test_klass index_name: new_index_name }

  let(:test_post)        { original_klass.create id: 1, text: 'test_post' }
  let(:test_post_2)      { new_klass.create      id: 2, text: 'other_post' }

  let(:elastic_client)   { Elasticsearch::Client.new(host: ES_HOST, log: false) }
  let(:alias_index)      { elastic_client.indices.put_alias(index: orig_index_name, name: orig_index_alias) }

  # Create the index (test_index) on the test_klass:
  before do
    original_klass.create_index!
    test_post
    original_klass.refresh_index!
  end

  it "copies the index" do
    ESReindex.copy! "#{ES_HOST}/#{orig_index_name}", "#{ES_HOST}/#{new_index_name}", {}
    expect(new_klass.find test_post.id).to be_present
  end

  it "copies the aliased index" do
    alias_index
    ESReindex.copy! "#{ES_HOST}/#{orig_index_alias}", "#{ES_HOST}/#{new_index_name}", {}
    expect(new_klass.find test_post.id).to be_present
  end

  context "when the destination index already exists" do

    # Create the index (test_index_clone) on the destination klass:
    before do
      new_klass.create_index!
      test_post_2
      new_klass.refresh_index!
    end

    it "merges it right on over" do
      ESReindex.copy! "#{ES_HOST}/#{orig_index_name}", "#{ES_HOST}/#{new_index_name}", {}
      expect(new_klass.find test_post.id).to   be_present
      expect(new_klass.find test_post_2.id).to be_present
    end

    context "with the remove option" do
      it "overwrites the destination index" do
        ESReindex.copy! "#{ES_HOST}/#{orig_index_name}", "#{ES_HOST}/#{new_index_name}", {remove: true}
        expect(new_klass.find test_post.id).to   be_present
        expect {
          new_klass.find test_post_2.id
        }.to raise_error Elasticsearch::Persistence::Repository::DocumentNotFound
      end
    end
  end
end
