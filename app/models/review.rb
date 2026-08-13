class Review < ApplicationRecord
  belongs_to :wash
  belongs_to :booking, optional: true
  has_one_attached :before_photo
  has_one_attached :after_photo

  validates :name, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
