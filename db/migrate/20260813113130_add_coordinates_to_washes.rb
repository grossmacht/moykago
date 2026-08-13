class AddCoordinatesToWashes < ActiveRecord::Migration[8.1]
  def change
    add_column :washes, :latitude, :decimal, precision: 9, scale: 6
    add_column :washes, :longitude, :decimal, precision: 9, scale: 6
  end
end
