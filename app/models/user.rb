class User < ApplicationRecord
  has_secure_password
  belongs_to :wash, optional: true

  enum :role, { owner: 0, admin: 1 }, default: :owner

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true

  before_validation { self.phone = phone.to_s.gsub(/[^\d+]/, "") }
end
