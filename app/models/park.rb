class Park < ApplicationRecord
  # validations
  validates_presence_of :plate
  validates_format_of :plate, :with => /[a-zA-Z]{3}-[0-9]{4}/i, :on => :create
end
