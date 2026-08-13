class Wash < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, :district, :address, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :open_hour, :close_hour, :bays, presence: true
  validates :commission_rate, numericality: { in: 0..100 }

  before_validation :ensure_slug

  DISTRICTS = [
    "Chilonzor", "Yunusobod", "Mirzo Ulug'bek", "Yakkasaroy", "Shayxontohur",
    "Olmazor", "Uchtepa", "Sergeli", "Yashnobod", "Mirobod", "Bektemir", "Yangihayot"
  ].freeze

  scope :featured, -> { where(featured: true) }

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

  private

  def ensure_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
