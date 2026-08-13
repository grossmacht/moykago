class Car < ApplicationRecord
  belongs_to :customer
  has_many :bookings, dependent: :nullify

  validate :model_or_plate_present

  def label
    [ make, model, plate ].reject(&:blank?).join(" ")
  end

  private

  def model_or_plate_present
    errors.add(:base, "mashina modeli yoki raqami kiritilishi kerak") if model.blank? && plate.blank?
  end
end
