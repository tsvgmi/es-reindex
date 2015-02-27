require 'spec_helper'

describe "reindex!", type: :integration do
  let(:orig_index_name)  { "test_index" }
  let(:new_index_name)   { "test_index_clone" }
  let(:orig_index_alias) { "test_index_alias" }

  let!(:original_klass)  { test_klass index_name: orig_index_name }
  let!(:new_klass)       { test_klass index_name: new_index_name, attributes: [:foo] }

  let(:test_post)        { original_klass.create id: 1, text: 'test_post' }

  let(:elastic_client)   { Elasticsearch::Client.new(host: ES_HOST, log: false) }
  let(:alias_index)      { elastic_client.indices.put_alias(index: orig_index_name, name: orig_index_alias) }

  # Create the index (test_index) on the test_klass:
  before do
    original_klass.create_index!
    test_post
    original_klass.refresh_index!
  end

  let(:reindexed_post)  { new_klass.find test_post.id }

  let(:reindex)         { ESReindex.reindex! "#{ES_HOST}/#{orig_index_name}", "#{ES_HOST}/#{new_index_name}", opts }
  let(:aliased_reindex) { ESReindex.reindex! "#{ES_HOST}/#{orig_index_alias}", "#{ES_HOST}/#{new_index_name}", opts }
  let(:mappings)        { ->{ new_klass.mappings } }
  let(:settings)        { ->{ new_klass.settings } }
  let(:other_opts)      { {} }
  let(:opts)            { {mappings: mappings, settings: settings}.merge other_opts }

  it "reindexes with the selected mappings" do
    reindex

    expect(reindexed_post.id).to   eq test_post.id
    expect(reindexed_post.text).to eq test_post.text
    expect(reindexed_post).to respond_to :foo
  end

  it "reindexes alias with the selected mappings" do
    alias_index

    aliased_reindex

    expect(reindexed_post.id).to   eq test_post.id
    expect(reindexed_post.text).to eq test_post.text
    expect(reindexed_post).to respond_to :foo
  end

  context "with a :unless guard" do
    let(:other_opts) do
      {
        unless: ->(sclient,dclient) {
          existing_properties = sclient.indices.get_mapping(index: orig_index_name)[orig_index_name]['mappings']['test_klass']['properties']
          existing_mappings = existing_properties.inject({}) do |result, (k,v)|
            result[k.to_sym] = {type: v['type']}
            result
          end
          new_mappings = klass_to_use_as_source.mappings.to_hash[:test_klass][:properties]
          existing_mappings.sort == new_mappings.sort
        }
      }
    end

    context "when the unless call returns true" do
      let(:klass_to_use_as_source) { original_klass }

      it "does not reindex" do
        reindex
        original_klass.refresh_index!
        expect(test_post.id).to be_present
        expect { test_post.foo}.to raise_error NoMethodError
      end
    end

    context "when the unless call returns false" do
      let(:klass_to_use_as_source) { new_klass }

      it "reindexes" do
        reindex
        expect(reindexed_post.id).to   eq test_post.id
        expect(reindexed_post.text).to eq test_post.text
        expect(reindexed_post).to respond_to :foo
      end
    end
  end
end
