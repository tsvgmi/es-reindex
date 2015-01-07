require 'coveralls'
Coveralls.wear!

require 'es-reindex'
require 'es-reindex/args_parser'

RSpec.configure do |config|
  config.tty = true

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

