# frozen_string_literal: true

require 'spec_helper'

describe FlightStats::HistoricalFlight do
  before(:all) do
    WebMock.allow_net_connect!
  end

  describe '#flights_departed_on_date' do
    it 'must return Iberia express - I2, MAD -> LPA and 321 aircraft type' do
      scheduled_flights = FlightStats::HistoricalFlight.flights_departed_on_date('IB', '3826', 2019, 7, 17)

      first_flight = scheduled_flights.first

      expect(first_flight.carrier_fs_code).to eq('I2')
      expect(first_flight.departure_airport_fs_code).to eq('MAD')
      expect(first_flight.arrival_airport_fs_code).to eq('LPA')
      expect(first_flight.flight_equipment.actual_equipment_iata_code).to eq('321')
    end
  end
end
