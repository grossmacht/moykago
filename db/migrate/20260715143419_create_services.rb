class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.references :wash, null: false, foreign_key: true
      t.string :name
      t.integer :price
      t.integer :duration_minutes

      t.timestamps
    end
  end
end
