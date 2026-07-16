# Bot suhbatini Telegram'siz sinash (smoke test).
# Ishga tushirish: bin/rails runner script/bot_simulation.rb

FakeChat    = Struct.new(:id)
FakeFrom    = Struct.new(:first_name)
FakeContact = Struct.new(:phone_number)
FakeMsg     = Struct.new(:chat, :text, :contact, :from)
FakeCb      = Struct.new(:id, :data, :message, :from)

class FakeApi
  attr_reader :sent
  def initialize = @sent = []
  def send_message(**kwargs) = @sent << kwargs
  def answer_callback_query(**) = nil
  def last = @sent.last
  def last_buttons
    kb = last[:reply_markup]
    kb = JSON.parse(kb, symbolize_names: true) if kb.is_a?(String)
    kb.is_a?(Hash) && kb[:inline_keyboard] ? kb[:inline_keyboard].flatten : []
  end
end

CHAT_ID = 990_001_122
BotSession.where(chat_id: CHAT_ID).delete_all
Booking.where(telegram_chat_id: CHAT_ID).delete_all

api = FakeApi.new
handler = Bot::Handler.new(api)
chat = FakeChat.new(CHAT_ID)
from = FakeFrom.new("Aziz")
failures = []
check = ->(name, cond, extra = "") {
  puts "#{cond ? 'PASS' : 'FAIL'} #{name} #{extra}"
  failures << name unless cond
}

msg = ->(text, contact: nil) { handler.handle(FakeMsg.new(chat, text, contact, from)) }
cb  = ->(data) { handler.handle(FakeCb.new("cb1", data, FakeMsg.new(chat, nil, nil, from), from)) }

# 1. /start
msg.call("/start")
check.call("start javobi", api.last[:text].include?("MoykaGo"))

# 2. Moyka topish -> tumanlar
msg.call("🚿 Moyka topish")
check.call("tumanlar chiqdi", api.last_buttons.any? { |b| b[:callback_data].to_s.start_with?("d:") })

# 3. Tuman tanlash
cb.call("d:Chilonzor")
wash_btn = api.last_buttons.find { |b| b[:callback_data].to_s.start_with?("w:") }
check.call("moykalar ro'yxati", !wash_btn.nil?, wash_btn&.dig(:text))

# 4. Moyka kartasi
cb.call(wash_btn[:callback_data])
svc_btn = api.last_buttons.find { |b| b[:callback_data].to_s.start_with?("s:") }
check.call("xizmatlar chiqdi", !svc_btn.nil?)

# 5. Xizmat -> sanalar
cb.call(svc_btn[:callback_data])
date_btn = api.last_buttons.find { |b| b[:callback_data].to_s.start_with?("dt:") }
check.call("sanalar chiqdi", !date_btn.nil?, date_btn&.dig(:text))

# 6. Ertangi kun -> soatlar (bugun kech bo'lishi mumkin)
tomorrow = (Date.current + 1).iso8601
cb.call("dt:#{tomorrow}")
slot_btn = api.last_buttons.find { |b| b[:callback_data].to_s.start_with?("sl:") }
check.call("bo'sh soatlar chiqdi", !slot_btn.nil?, slot_btn&.dig(:text))

# 7. Soat -> telefon so'raladi
cb.call(slot_btn[:callback_data])
check.call("telefon so'raldi", api.last[:text].include?("Telefon") || api.last[:text].include?("raqam"))

# 8. Kontakt yuborish -> bron yaratiladi
msg.call(nil, contact: FakeContact.new("+998915550099"))
booking = Booking.find_by(telegram_chat_id: CHAT_ID)
check.call("bron yaratildi", !booking.nil? && api.last[:text].include?(booking.code), booking&.code)
check.call("bron ma'lumoti to'g'ri", booking&.customer_name == "Aziz" && booking&.date == Date.current + 1)

# 9. Xato telefon rad etiladi (yangi suhbat holati)
BotSession.find_by(chat_id: CHAT_ID).update!(step: "phone",
  payload: { wash_id: booking.wash_id, service_id: booking.service_id,
             date: tomorrow, slot: slot_btn[:callback_data].split(":", 2)[1], name: "Aziz" }.to_json)
before = Booking.count
msg.call("salom")
check.call("xato raqam rad etildi", Booking.count == before && api.last[:text].include?("noto'g'ri"))

# 10. Band slotga qayta bron -> xato xabari
msg.call(booking.customer_phone) # to'g'ri raqam, lekin slot band (bays ga bog'liq) — yoki yangi bron bo'ladi
# bays > 1 bo'lsa bron bo'lishi normal; shuning uchun faqat javob kelganini tekshiramiz
check.call("javob qaytdi", api.last[:text].present?)

# 11. Bronlarim
msg.call("📋 Bronlarim")
check.call("bronlarim ro'yxati", api.sent.last(3).any? { |m| m[:text].include?(booking.code) })

# 12. Bekor qilish
cb.call("c:#{booking.code}")
check.call("bekor qilindi", booking.reload.bekor?)

# Tozalash
Booking.where(telegram_chat_id: CHAT_ID).delete_all
BotSession.where(chat_id: CHAT_ID).delete_all

puts failures.empty? ? "\nHAMMASI O'TDI ✅" : "\nXATOLAR: #{failures.join(', ')}"
exit(failures.empty? ? 0 : 1)
