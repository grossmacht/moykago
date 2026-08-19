class AddWashTypeToWashes < ActiveRecord::Migration[8.1]
  def change
    add_column :washes, :wash_type, :string, default: "full_service", null: false
    add_index :washes, :wash_type
  end
end
