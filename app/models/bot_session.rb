class BotSession < ApplicationRecord
  validates :chat_id, presence: true, uniqueness: true

  def data
    JSON.parse(payload.presence || "{}")
  rescue JSON::ParserError
    {}
  end

  def merge!(hash)
    update!(payload: data.merge(hash.stringify_keys).to_json)
  end

  def reset!(step: "idle")
    update!(step: step, payload: "{}")
  end
end
