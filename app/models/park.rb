class Park < ApplicationRecord

  class ParkingAlreadyPaidError < StandardError
  end

  class VehicleAlreadyLeftError < StandardError
  end

  class LeavingUnpaidParkingError < StandardError
  end
  
  # validations
  validates_presence_of :plate
  validates_format_of :plate, :with => /[a-zA-Z]{3}-[0-9]{4}/i, :on => :create
  validate :check_plate_is_not_parked, :on => :create

  def pay
    raise ParkingAlreadyPaidError if self.paid.present?
    self.paid = true
    self.save()
  end

  def out
    raise VehicleAlreadyLeftError if self.left.present?
    raise LeavingUnpaidParkingError if self.paid.blank?
    self.left = true
    self.left_in = Time.now
    self.save()
  end

  def getInfo
    if self.left_in.nil?
      time_spent = 'Still parked'
    else
      time_spent = (self.left_in - self.created_at)
      time_minutes = (time_spent / 1.minute).round
    end
    return {id: self.id, time: "#{time_minutes} minute(s)", paid: self.paid, left: self.left}
  end

  def check_plate_is_not_parked
    if new_record?
      if Park.where(plate: plate).where(left: false).count > 0
        errors.add(:base, 'There is a car already parked with the same plate')
      end
    end
  end
end
