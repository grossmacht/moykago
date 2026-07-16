class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :wash, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.date :date
      t.string :slot
      t.string :customer_name
      t.string :customer_phone
      t.string :car_model
      t.integer :status, default: 0, null: false
      t.string :code

      t.timestamps
    end
    add_index :bookings, :code, unique: true
    add_index :bookings, :customer_phone
    add_index :bookings, [ :wash_id, :date, :slot ]
  end
end
