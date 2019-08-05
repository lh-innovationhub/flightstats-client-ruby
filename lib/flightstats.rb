# frozen_string_literal: true

module FlightStats
  # The exception class from which all FlightStats exceptions inherit.
  class Error < StandardError
    def set_message(message)
      @message = message
    end

    # @return [String]
    def to_s
      defined?(@message) && @message || super
    end
  end

  # This exception is raised if FlightStats has not been configured.
  class ConfigurationError < Error
  end

  class << self
    # @return [String] An APP id.
    # @raise [ConfigurationError] If not configured.
    def app_id
      defined?(@app_id) && @app_id || raise(
        ConfigurationError, 'FlightStats.app_id not configured'
      )
    end
    attr_writer :app_id

    # @return [String] An APP key.
    # @raise [ConfigurationError] If not configured.
    def app_key
      defined?(@app_key) && @app_key || raise(
        ConfigurationError, 'FlightStats.app_key not configured'
      )
    end
    attr_writer :app_key

    def alert_deliveries
      defined? @alert_deliveries && @alert_deliveries || raise(
        ConfigurationError, 'FlightStats.alert_deliveries not configured'
      )
    end
    attr_writer :alert_deliveries

    def alert_type
      allowed_formats = %w[JSON XML]
      return 'JSON' if @alert_type.nil?

      unless allowed_formats.include?(@alert_type)
        raise(
          ConfigurationError, "FlightStats.alert_type is not valid, allowed: 'JSON', 'XML'"
        )
      end
      @alert_type
    end
    attr_writer :alert_type

    # Assigns a logger to log requests/responses and more.
    #
    # @return [Logger, nil]
    # @example
    #   require 'logger'
    #   FlightStats.logger = Logger.new STDOUT
    # @example Rails applications automatically log to the Rails log:
    #   FlightStats.logger = Rails.logger
    # @example Turn off logging entirely:
    #   FlightStats.logger = nil # Or FlightStats.logger = Logger.new nil
    attr_accessor :logger

    # Convenience logging method includes a Logger#progname dynamically.
    # @return [true, nil]
    def log(level, message)
      logger.send(level, name) { message }
    end

    if RUBY_VERSION <= '1.9.0'
      def const_defined?(sym, inherit = false)
        raise ArgumentError, 'inherit must be false' if inherit

        super sym
      end

      def const_get(sym, inherit = false)
        raise ArgumentError, 'inherit must be false' if inherit

        super sym
      end
    end
  end

  require 'flightstats/version'

  require 'flightstats/helper'
  require 'flightstats/api/errors'
  require 'flightstats/api/net_http_adapter'

  require 'flightstats/resource'

  require 'flightstats/abstract_date'
  require 'flightstats/actual_gate_departure'
  require 'flightstats/actual_runway_departure'
  require 'flightstats/airline'
  require 'flightstats/airport'
  require 'flightstats/airport_resources'
  require 'flightstats/appendix'
  require 'flightstats/arrival_date'
  require 'flightstats/codeshare'
  require 'flightstats/departure_date'
  require 'flightstats/equipment'
  require 'flightstats/estimated_gate_arrival'
  require 'flightstats/estimated_gate_departure'
  require 'flightstats/estimated_runway_arrival'
  require 'flightstats/estimated_runway_departure'
  require 'flightstats/extended_options'
  require 'flightstats/flight'
  require 'flightstats/flight_durations'
  require 'flightstats/flight_equipment'
  require 'flightstats/flight_id'
  require 'flightstats/flight_leg'
  require 'flightstats/flight_plan_planned_arrival'
  require 'flightstats/flight_plan_planned_departure'
  require 'flightstats/flight_status'
  require 'flightstats/operational_times'
  require 'flightstats/operator'
  require 'flightstats/published_arrival'
  require 'flightstats/published_departure'
  require 'flightstats/schedule'
  require 'flightstats/scheduled_flight'
  require 'flightstats/scheduled_gate_arrival'
  require 'flightstats/scheduled_gate_departure'
  require 'flightstats/actual_gate_arrival'
  require 'flightstats/actual_runway_arrival'
  require 'flightstats/historical_flight'

  require 'flightstats/weather'
  require 'flightstats/metar'
  require 'flightstats/taf'
  require 'flightstats/forecast'
  require 'flightstats/condition'
  require 'flightstats/wind'
  require 'flightstats/visibility'
  require 'flightstats/weather_condition'
  require 'flightstats/sky_condition'
  require 'flightstats/runway_visual_range'
  require 'flightstats/obscuration'
  require 'flightstats/tag'
  require 'flightstats/zone_forecast'
  require 'flightstats/zone'
  require 'flightstats/city'
  require 'flightstats/zone_name'
  require 'flightstats/day_forecast'

  require 'flightstats/rating'
  require 'flightstats/alert'

  require 'flightstats/fids_data'

  require 'flightstats/api'
end
