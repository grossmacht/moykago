class Customer < ApplicationRecord
  has_secure_password

  has_many :bookings, dependent: :nullify
  has_many :cars, dependent: :destroy
  belongs_to :referred_by, class_name: "Customer", optional: true
  has_many :referrals, class_name: "Customer", foreign_key: :referred_by_id, inverse_of: :referred_by, dependent: :nullify

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true

  before_validation { self.phone = phone.to_s.gsub(/[^\d+]/, "") }
  before_create :generate_referral_code

  LOYALTY_EVERY = 5

  def completed_count_at(wash)
    bookings.where(wash: wash, status: :bajarildi).count
  end

  def stamp_progress_at(wash)
    completed_count_at(wash) % LOYALTY_EVERY
  end

  def stamp_discount_eligible?(wash)
    count = completed_count_at(wash)
    count.positive? && (count % LOYALTY_EVERY).zero?
  end

  private

  def generate_referral_code
    loop do
      self.referral_code = SecureRandom.alphanumeric(6).upcase
      break unless Customer.exists?(referral_code: referral_code)
    end
  end
end
