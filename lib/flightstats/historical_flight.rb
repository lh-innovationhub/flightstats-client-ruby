# frozen_string_literal: true

module FlightStats
  class HistoricalFlight < Resource
    attr_accessor :endpoint

    @@base_path = '/flex/flightstatus/historical/rest/v3/json'

    class << self
      def flights_departed_on_date(carrier_fs_code, flight_number, year, month, day, params = {}, options = {})
        from_response API.get("#{base_path}/flight/status/#{carrier_fs_code}/#{flight_number}/dep/#{year}/#{month}/#{day}", params, options), 'flightStatuses'
      end

      def base_path
        @@base_path
      end
    end
  end
end
