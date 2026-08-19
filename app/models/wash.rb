class Wash < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many_attached :photos

  validates :name, :district, :address, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :open_hour, :close_hour, :bays, presence: true
  validates :commission_rate, numericality: { in: 0..100 }
  validates :wash_type, inclusion: { in: -> { WASH_TYPES } }

  before_validation :ensure_slug

  DISTRICTS = [
    "Chilonzor", "Yunusobod", "Mirzo Ulug'bek", "Yakkasaroy", "Shayxontohur",
    "Olmazor", "Uchtepa", "Sergeli", "Yashnobod", "Mirobod", "Bektemir", "Yangihayot"
  ].freeze

  WASH_TYPES = %w[full_service self_service automatic].freeze

  scope :featured, -> { where(featured: true) }
  scope :by_type, ->(type) { where(wash_type: type) if type.present? }

  def full_service? = wash_type == "full_service"
  def self_service? = wash_type == "self_service"
  def automatic? = wash_type == "automatic"

  def to_param = slug

  def slots
    (open_hour...close_hour).map { |h| format("%02d:00", h) }
  end

  def slot_taken?(date, slot)
    bookings.where(date: date, slot: slot).where.not(status: :bekor).count >= bays
  end

  def slot_past?(date, slot)
    date == Date.current && slot.to_i <= Time.current.hour
  end

  def rating
    avg = reviews.average(:rating)
    avg ? avg.round(1) : nil
  end

  def price_from
    services.minimum(:price)
  end

  def work_hours
    format("%02d:00 – %02d:00", open_hour, close_hour)
  end

  def gmv_between(range)
    bookings.where(date: range, status: :bajarildi).sum(:amount_charged)
  end

  def commission_owed_between(range)
    bookings.where(date: range, status: :bajarildi).sum(:commission_amount)
  end

  EARTH_RADIUS_KM = 6371.0

  def distance_km_from(lat, lng)
    return nil if latitude.blank? || longitude.blank? || lat.blank? || lng.blank?
    lat1, lng1, lat2, lng2 = [ latitude, longitude, lat, lng ].map { |v| v.to_f * Math::PI / 180 }
    dlat = lat2 - lat1
    dlng = lng2 - lng1
    a = Math.sin(dlat / 2)**2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlng / 2)**2
    EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  private

  def ensure_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
