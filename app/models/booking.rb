class Booking < ApplicationRecord
  belongs_to :wash
  belongs_to :service
  has_one :review, dependent: :nullify

  enum :status, { yangi: 0, tasdiqlandi: 1, bajarildi: 2, bekor: 3 }, default: :yangi

  validates :date, :slot, :customer_name, :customer_phone, presence: true
  validate :date_not_past
  validate :slot_available, on: :create

  before_validation :normalize_phone
  before_create :generate_code

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

  private

  def normalize_phone
    self.customer_phone = customer_phone.to_s.gsub(/[^\d+]/, "")
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
