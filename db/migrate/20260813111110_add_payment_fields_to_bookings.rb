class AddPaymentFieldsToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :amount_charged, :integer
    add_column :bookings, :payment_method, :integer
    add_column :bookings, :commission_rate, :decimal, precision: 5, scale: 2
    add_column :bookings, :commission_amount, :integer
  end
end
