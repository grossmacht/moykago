class Review < ApplicationRecord
  belongs_to :wash
  belongs_to :booking, optional: true

  validates :name, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
end
