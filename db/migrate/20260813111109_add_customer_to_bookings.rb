class AddCustomerToBookings < ActiveRecord::Migration[8.1]
  def change
    add_reference :bookings, :customer, null: true, foreign_key: true
  end
end
