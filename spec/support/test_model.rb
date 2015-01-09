require 'elasticsearch/persistence/model'

def test_klass(index_name:)
  Class.new do
    def self.name; 'TestKlass'; end

    include Elasticsearch::Persistence::Model

    gateway.client Elasticsearch::Client.new host: ES_HOST
    gateway.index = index_name

    attribute :id
    attribute :text
  end
end
