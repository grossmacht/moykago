class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone
      t.string :password_digest
      t.integer :role, default: 0, null: false
      t.references :wash, null: true, foreign_key: true

      t.timestamps
    end
  end
end
