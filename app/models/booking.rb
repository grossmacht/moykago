class Booking < ApplicationRecord
  belongs_to :wash
  belongs_to :service
  belongs_to :customer, optional: true
  belongs_to :car, optional: true
  has_one :review, dependent: :nullify

  enum :status, { yangi: 0, tasdiqlandi: 1, bajarildi: 2, bekor: 3 }, default: :yangi
  enum :payment_method, { naqd: 0, karta: 1 }, prefix: true

  validates :date, :slot, :customer_name, :customer_phone, presence: true
  validate :date_not_past
  validate :slot_available, on: :create

  before_validation :normalize_phone
  before_validation :auto_link_customer_by_phone
  before_create :generate_code
  after_create :save_car_for_customer

  STATUS_LABELS = {
    "yangi"       => "Yangi",
    "tasdiqlandi" => "Tasdiqlandi",
    "bajarildi"   => "Bajarildi",
    "bekor"       => "Bekor qilindi"
  }.freeze

  def status_label = STATUS_LABELS[status]

  def cancellable?
    (yangi? || tasdiqlandi?) && date >= Date.current
  end

  def car_label
    car&.label.presence || car_model.presence || "—"
  end

  # Bron "bajarildi" deb belgilanganda shu yerdan o'tadi — narx/komissiya
  # bron yaratilgan paytda emas, aynan shu yerda, bir marta hisoblanadi.
  def complete!(payment_method:, amount_charged: nil)
    return if bajarildi?

    charge = amount_charged || service.price
    rate = wash.commission_rate
    update!(
      status: :bajarildi,
      payment_method: payment_method,
      amount_charged: charge,
      commission_rate: rate,
      commission_amount: (charge * rate / 100.0).round
    )
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

  def generate_code
    loop do
      self.code = "M#{SecureRandom.alphanumeric(5).upcase}"
      break unless Booking.exists?(code: code)
    end
  end

  def date_not_past
    return if date.blank?
    errors.add(:date, "o'tgan sanaga bron qilib bo'lmaydi") if date < Date.current
  end

  def slot_available
    return if wash.blank? || date.blank? || slot.blank?
    unless wash.slots.include?(slot)
      errors.add(:slot, "noto'g'ri vaqt tanlandi")
      return
    end
    if wash.slot_past?(date, slot)
      errors.add(:slot, "bu vaqt allaqachon o'tib ketgan")
    elsif wash.slot_taken?(date, slot)
      errors.add(:slot, "bu vaqt band, boshqasini tanlang")
    end
  end
end
