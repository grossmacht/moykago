class CreateCars < ActiveRecord::Migration[8.1]
  def change
    create_table :cars do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :plate
      t.string :make
      t.string :model

      t.timestamps
    end
  end
end
