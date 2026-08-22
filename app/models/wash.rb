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

  # SAM (o'zi yuvish) boksda mijozlar ancha tez almashadi — soatlik emas,
  # 15 daqiqalik oraliqda band qilinadi. To'liq xizmat va avtomat moykalar
  # uchun soatlik jadval yetarli.
  def slots
    return quarter_hour_slots if self_service?
    (open_hour...close_hour).map { |h| format("%02d:00", h) }
  end

  def slot_taken?(date, slot)
    bookings.where(date: date, slot: slot).where.not(status: :bekor).count >= bays
  end

  def slot_past?(date, slot)
    return false unless date == Date.current
    hour, minute = slot.split(":").map(&:to_i)
    now = Time.current
    hour < now.hour || (hour == now.hour && minute <= now.min)
  end

  def rating
    avg = reviews.average(:rating)
    avg ? avg.round(1) : nil
  end

  # "Arzonidan" saralashda daqiqasiga narxlanadigan xizmatlarni belgilangan
  # narxlar bilan solishtirsa bo'ladigan qilib, tavsiya etilgan davomiylikka
  # ko'paytirib, taxminiy umumiy narxga keltiradi.
  def price_from
    cheapest = services.min_by(&:price)
    return nil unless cheapest
    cheapest.per_minute? ? cheapest.price * cheapest.duration_minutes : cheapest.price
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

  def quarter_hour_slots
    (open_hour * 4...close_hour * 4).map { |q| format("%02d:%02d", q / 4, (q % 4) * 15) }
  end
end
