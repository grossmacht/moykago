class CreateBotSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :bot_sessions do |t|
      t.bigint :chat_id, null: false
      t.string :step, default: "idle", null: false
      t.text :payload

      t.timestamps
    end
    add_index :bot_sessions, :chat_id, unique: true
  end
end
