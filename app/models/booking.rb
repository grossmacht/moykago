class Booking < ApplicationRecord
  belongs_to :wash
  belongs_to :service
  belongs_to :customer, optional: true
  belongs_to :car, optional: true
  belongs_to :promo_code, optional: true
  has_one :review, dependent: :nullify

  enum :status, { yangi: 0, tasdiqlandi: 1, bajarildi: 2, bekor: 3 }, default: :yangi
  enum :payment_method, { naqd: 0, karta: 1 }, prefix: true

  validates :date, :slot, :customer_name, :customer_phone, presence: true
  validate :date_not_past
  validate :slot_available, on: :create
  validate :self_service_same_day

  before_validation :normalize_phone
  before_validation :auto_link_customer_by_phone
  before_create :generate_code
  after_create :save_car_for_customer

  STATUSES = %w[yangi tasdiqlandi bajarildi bekor].freeze

  def status_label = I18n.t("bookings.status.#{status}")

  def cancellable?
    (yangi? || tasdiqlandi?) && date >= Date.current
  end

  def car_label
    car&.label.presence || car_model.presence || "—"
  end

  REFERRAL_BONUS = 10_000

  # Bron "bajarildi" deb belgilanganda shu yerdan o'tadi — narx/komissiya
  # bron yaratilgan paytda emas, aynan shu yerda, bir marta hisoblanadi.
  def complete!(payment_method:, amount_charged: nil)
    return if bajarildi?

    charge = amount_charged || (service.price - discount_amount.to_i)
    rate = wash.commission_rate
    transaction do
      update!(
        status: :bajarildi,
        payment_method: payment_method,
        amount_charged: charge,
        commission_rate: rate,
        commission_amount: (charge * rate / 100.0).round
      )
      credit_referral_bonus!
    end
  end

  private

  def normalize_phone
    self.customer_phone = customer_phone.to_s.gsub(/[^\d+]/, "")
  end

  def auto_link_customer_by_phone
    return if customer_id.present? || customer_phone.blank?
    self.customer = Customer.find_by(phone: customer_phone.to_s.gsub(/[^\d+]/, ""))
  end

  # Mijoz tizimga kirib, erkin matn bilan mashina yozsa — keyingi safar
  # tanlashi uchun "Kabinetim"ga avtomatik saqlanadi.
  def save_car_for_customer
    return if customer.blank? || car_id.present? || car_model.blank?
    car = customer.cars.find_or_create_by(model: car_model.strip)
    update_column(:car_id, car.id) if car.persisted?
  end

  # Referal bonusi faqat bitta shartga javob bersa va faqat bir marta beriladi:
  # taklif qilingan mijozning ILK bajarilgan broni shu bo'lsa.
  def credit_referral_bonus!
    return unless customer&.referred_by
    return if customer.referral_bonus_granted?
    return unless customer.bookings.where(status: :bajarildi).count == 1

    customer.referred_by.increment!(:bonus_balance, REFERRAL_BONUS)
    customer.update!(referral_bonus_granted: true)
  end

  def generate_code
    loop do
      self.code = "M#{SecureRandom.alphanumeric(5).upcase}"
      break unless Booking.exists?(code: code)
    end
  end

  def date_not_past
    return if date.blank?
    errors.add(:date, :past_date) if date < Date.current
  end

  # SAM boks bron emas, "kelayapman" bildirishnomasi — shuning uchun faqat
  # bugungi kunga amal qiladi, oldindan uzoq muddatga band qilinmaydi.
  def self_service_same_day
    return if date.blank? || wash.blank? || !wash.self_service?
    errors.add(:date, :self_service_future_date) if date != Date.current
  end

  def slot_available
    return if wash.blank? || date.blank? || slot.blank?
    unless wash.slots.include?(slot)
      errors.add(:slot, :invalid_slot)
      return
    end
    if wash.slot_past?(date, slot)
      errors.add(:slot, :slot_past)
    elsif wash.slot_taken?(date, slot)
      errors.add(:slot, :slot_taken)
    end
  end
end
