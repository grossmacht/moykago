class Service < ApplicationRecord
  belongs_to :wash
  has_many :bookings, dependent: :restrict_with_error
  has_one_attached :photo

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :pricing_unit, inclusion: { in: -> { PRICING_UNITS } }

  PRICING_UNITS = %w[fixed per_minute].freeze

  def per_minute? = pricing_unit == "per_minute"
end
