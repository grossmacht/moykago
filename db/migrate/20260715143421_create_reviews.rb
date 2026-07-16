class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :wash, null: false, foreign_key: true
      t.references :booking, null: true, foreign_key: true
      t.string :name
      t.integer :rating
      t.text :comment

      t.timestamps
    end
  end
end
