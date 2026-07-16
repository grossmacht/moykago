class CreateWashes < ActiveRecord::Migration[8.1]
  def change
    create_table :washes do |t|
      t.string :name
      t.string :slug
      t.string :district
      t.string :address
      t.string :phone
      t.text :description
      t.integer :open_hour, default: 8
      t.integer :close_hour, default: 22
      t.integer :bays, default: 2
      t.boolean :featured, default: false

      t.timestamps
    end
    add_index :washes, :slug, unique: true
    add_index :washes, :district
  end
end
