class PromoCode < ApplicationRecord
  has_many :bookings, dependent: :nullify

  enum :discount_type, { percent: 0, fixed: 1 }

  validates :code, presence: true, uniqueness: true
  validates :value, numericality: { greater_than: 0 }
  validates :value, numericality: { less_than_or_equal_to: 100 }, if: :percent?

  before_validation { self.code = code.to_s.strip.upcase }

  def usable?(amount)
    return false if expires_at.present? && expires_at < Time.current
    return false if usage_limit.present? && used_count.to_i >= usage_limit
    return false if min_amount.present? && amount < min_amount
    true
  end

  def discount_for(amount)
    raw = percent? ? (amount * value / 100.0).round : value
    [ raw, amount ].min
  end
end
