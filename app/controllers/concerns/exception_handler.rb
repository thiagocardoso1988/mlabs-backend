module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :unprocessable_entity)
    end

    rescue_from Park::ParkingAlreadyPaidError do |e|
      json_response({ message: 'Parking already paid' }, :unprocessable_entity)
    end

    rescue_from Park::VehicleAlreadyLeftError do |e|
      json_response({ message: 'Vehicle already left' }, :unprocessable_entity)
    end

    rescue_from Park::LeavingUnpaidParkingError do |e|
      json_response({ message: 'Can\'t leave without paying' }, :unprocessable_entity)
    end
  end
end