class CreatePromoCodes < ActiveRecord::Migration[8.1]
  def change
    create_table :promo_codes do |t|
      t.string :code, null: false
      t.integer :discount_type, null: false, default: 0
      t.integer :value, null: false
      t.datetime :expires_at
      t.integer :usage_limit
      t.integer :used_count, null: false, default: 0
      t.integer :min_amount

      t.timestamps
    end
    add_index :promo_codes, :code, unique: true
  end
end
