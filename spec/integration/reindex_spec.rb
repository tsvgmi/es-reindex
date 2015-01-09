require 'spec_helper'

describe "reindex!", type: :integration do
  let(:orig_index_name)  { "test_index" }
  let(:new_index_name)   { "test_index_clone" }

  let!(:original_klass)  { test_klass index_name: orig_index_name }
  let!(:new_klass)       { test_klass index_name: new_index_name, attributes: [:foo] }

  let(:test_post)        { original_klass.create id: 1, text: 'test_post' }
  let(:test_post_2)      { new_klass.create      id: 2, text: 'other_post' }

  # Create the index (test_index) on the test_klass:
  before do
    original_klass.create_index!
    test_post
    original_klass.refresh_index!
  end

  let(:reindexed_post) { new_klass.find test_post.id }

  it "reindexes with the selected mappings" do
    ESReindex.reindex! "#{ES_HOST}/#{orig_index_name}", "#{ES_HOST}/#{new_index_name}",
      mappings: -> { new_klass.mappings },
      settings: -> { new_klass.settings }

    expect(reindexed_post.id).to   eq test_post.id
    expect(reindexed_post.text).to eq test_post.text
    expect(reindexed_post).to respond_to :foo
  end
end
