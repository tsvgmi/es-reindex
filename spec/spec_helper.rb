require 'coveralls'
Coveralls.wear!

require 'es-reindex'
require 'es-reindex/args_parser'

ES_HOST = ENV['ES_HOST'] || ESReindex::DEFAULT_URL

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.tty = true

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  ESReindex.logger = Logger.new(STDERR)
  ESReindex.logger.level = Logger::WARN

  # Make sure our indexes are clear for a fresh start
  config.before type: :integration do
    Elasticsearch::Client.new(host: ES_HOST).indices.tap do |es|
      es.delete index: 'test*'
    end
  end
end
