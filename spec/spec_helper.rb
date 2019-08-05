# frozen_string_literal: true

require 'bundler'

require 'rspec'
RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = 'documentation'
end

require 'flightstats'
require 'byebug'
# Update these if you want to run remote tests (rake test:remote:spec)
FlightStats.app_id = 'test_app_id'
FlightStats.app_key = 'test_key'
FlightStats.alert_deliveries = 'smtp://example@email.com'

require 'logger'
FlightStats.logger = Logger.new STDOUT
FlightStats.logger.level = Logger::INFO
