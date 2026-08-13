class AddPromoCodeToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :promo_code, null: true, foreign_key: true
    add_column :bookings, :discount_amount, :integer
  end
end
