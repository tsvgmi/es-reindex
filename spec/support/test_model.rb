require 'elasticsearch/persistence/model'

def test_klass(options)
  index_name  = options[:index_name]
  extra_attrs = options[:attributes] || []

  Class.new do
    def self.name; 'TestKlass'; end

    include Elasticsearch::Persistence::Model

    gateway.client Elasticsearch::Client.new host: ES_HOST
    gateway.index = index_name

    attribute :id
    attribute :text

    extra_attrs.each { |att| attribute att }
  end
end
