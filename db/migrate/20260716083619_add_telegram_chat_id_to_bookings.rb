class AddTelegramChatIdToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :telegram_chat_id, :bigint
    add_index :bookings, :telegram_chat_id
  end
end
