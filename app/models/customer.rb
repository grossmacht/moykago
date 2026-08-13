class Customer < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :nullify
  has_many :cars, dependent: :destroy

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true

  before_validation { self.phone = phone.to_s.gsub(/[^\d+]/, "") }
end
