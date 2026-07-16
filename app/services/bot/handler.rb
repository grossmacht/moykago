# MoykaGo Telegram bot suhbat mantig'i.
# `api` — Telegram::Bot::Api yoki testda uni taqlid qiluvchi obyekt.
module Bot
  class Handler
    BTN_FIND   = "🚿 Moyka topish"
    BTN_MINE   = "📋 Bronlarim"
    BTN_PHONE  = "📱 Raqamimni yuborish"

    MAIN_KB = {
      keyboard: [ [ { text: BTN_FIND }, { text: BTN_MINE } ] ],
      resize_keyboard: true, is_persistent: true
    }.freeze

    PHONE_KB = {
      keyboard: [ [ { text: BTN_PHONE, request_contact: true } ] ],
      resize_keyboard: true, one_time_keyboard: true
    }.freeze

    UZ_MONTHS = %w[yanvar fevral mart aprel may iyun iyul avgust sentabr oktabr noyabr dekabr].freeze
    UZ_DAYS = %w[Yak Du Se Chor Pay Ju Shan].freeze

    def initialize(api)
      @api = api
    end

    def handle(update)
      if update.respond_to?(:data) && update.data
        handle_callback(update)
      elsif update.respond_to?(:chat) && update.chat
        handle_message(update)
      end
    end

    private

    # ---------- Oddiy xabarlar ----------

    def handle_message(msg)
      chat_id = msg.chat.id
      session = BotSession.find_or_create_by!(chat_id: chat_id)
      text = msg.text.to_s.strip

      if msg.respond_to?(:contact) && msg.contact
        return on_phone(chat_id, session, msg.contact.phone_number)
      end

      case text
      when "/start"
        session.reset!
        send_text(chat_id,
          "Assalomu alaykum! 👋\n\n" \
          "MoykaGo — Toshkentda avtomoyka bron qilish xizmati.\n" \
          "Moykani tanlang, qulay vaqtga yoziling — kelganingizda joy tayyor. " \
          "To'lov joyida (naqd yoki karta), bron bepul.\n\n" \
          "Boshlash uchun «#{BTN_FIND}» tugmasini bosing.",
          reply_markup: MAIN_KB)
      when BTN_FIND, "/moyka"
        session.reset!
        show_districts(chat_id)
      when BTN_MINE, "/bronlarim"
        show_my_bookings(chat_id, session)
      else
        case session.step
        when "phone"        then on_phone(chat_id, session, text)
        when "lookup_phone" then on_lookup_phone(chat_id, session, text)
        else
          send_text(chat_id,
            "Tushunmadim 🤔 Quyidagi tugmalardan foydalaning:",
            reply_markup: MAIN_KB)
        end
      end
    end

    # ---------- Inline tugmalar ----------

    def handle_callback(cb)
      chat_id = cb.message.chat.id
      session = BotSession.find_or_create_by!(chat_id: chat_id)
      answer(cb)

      key, value = cb.data.split(":", 2)
      case key
      when "d"    then show_washes(chat_id, value)
      when "w"    then show_wash(chat_id, session, value.to_i)
      when "s"    then on_service(chat_id, session, value.to_i)
      when "dt"   then on_date(chat_id, session, value)
      when "sl"   then on_slot(chat_id, session, cb, value)
      when "c"    then on_cancel(chat_id, value)
      when "back" then show_districts(chat_id)
      end
    end

    # ---------- Bron oqimi ----------

    def show_districts(chat_id)
      counts = Wash.group(:district).count
      districts = Wash::DISTRICTS.select { |d| counts[d].to_i.positive? }
      rows = districts.each_slice(2).map { |pair|
        pair.map { |d| { text: "#{d} (#{counts[d]})", callback_data: "d:#{d}" } }
      }
      send_text(chat_id, "📍 Qaysi tumandan qidiramiz?",
        reply_markup: { inline_keyboard: rows })
    end

    def show_washes(chat_id, district)
      washes = Wash.includes(:services, :reviews).where(district: district).sort_by { |w| -(w.rating || 0) }
      return send_text(chat_id, "Bu tumanda hozircha moyka yo'q.") if washes.empty?

      rows = washes.map { |w|
        price = w.price_from ? " · #{fmt_som(w.price_from)} dan" : ""
        [ { text: "#{w.name} · 💧#{w.rating || 'yangi'}#{price}", callback_data: "w:#{w.id}" } ]
      }
      rows << [ { text: "⬅️ Tumanlar", callback_data: "back:d" } ]
      send_text(chat_id, "🚿 #{district} tumanidagi moykalar:",
        reply_markup: { inline_keyboard: rows })
    end

    def show_wash(chat_id, session, wash_id)
      wash = Wash.find_by(id: wash_id)
      return send_text(chat_id, "Moyka topilmadi.") unless wash

      session.merge!(wash_id: wash.id)
      lines = [ "🚿 #{wash.name}",
                "📍 #{wash.address} (#{wash.district})",
                "🕐 #{wash.work_hours} · #{wash.bays} post" ]
      lines << "💧 Reyting: #{wash.rating} (#{wash.reviews.size} sharh)" if wash.rating
      lines << "📞 #{wash.phone}" if wash.phone.present?
      lines << "" << "Xizmatni tanlang:"

      rows = wash.services.order(:price).map { |s|
        [ { text: "#{s.name} — #{fmt_som(s.price)}", callback_data: "s:#{s.id}" } ]
      }
      rows << [ { text: "⬅️ Orqaga", callback_data: "d:#{wash.district}" } ]
      send_text(chat_id, lines.join("\n"), reply_markup: { inline_keyboard: rows })
    end

    def on_service(chat_id, session, service_id)
      service = Service.find_by(id: service_id)
      return send_text(chat_id, "Xizmat topilmadi.") unless service

      session.merge!(wash_id: service.wash_id, service_id: service.id)
      rows = (0..6).map { |i| Date.current + i }.each_slice(2).map { |pair|
        pair.map { |d|
          label = i_label(d)
          { text: label, callback_data: "dt:#{d.iso8601}" }
        }
      }
      send_text(chat_id, "📅 Qaysi kunga?", reply_markup: { inline_keyboard: rows })
    end

    def on_date(chat_id, session, date_str)
      date = Date.parse(date_str) rescue Date.current
      wash = Wash.find_by(id: session.data["wash_id"])
      return restart(chat_id, session) unless wash

      free = wash.slots.reject { |s| wash.slot_taken?(date, s) || wash.slot_past?(date, s) }
      if free.empty?
        return send_text(chat_id, "#{i_label(date)} kuni bo'sh joy yo'q 😕 Boshqa kunni tanlang.",
          reply_markup: { inline_keyboard: [ [ { text: "📅 Boshqa kun", callback_data: "s:#{session.data['service_id']}" } ] ] })
      end

      session.merge!(date: date.iso8601)
      rows = free.each_slice(4).map { |slice|
        slice.map { |s| { text: s, callback_data: "sl:#{s}" } }
      }
      send_text(chat_id, "🕐 #{i_label(date)} — qulay soatni tanlang:",
        reply_markup: { inline_keyboard: rows })
    end

    def on_slot(chat_id, session, cb, slot)
      session.merge!(slot: slot, name: cb.from&.first_name.presence || "Mijoz")
      session.update!(step: "phone")
      send_text(chat_id,
        "Deyarli tayyor! 📱 Telefon raqamingizni yuboring — " \
        "tugmani bosing yoki yozing (masalan: +998901234567).",
        reply_markup: PHONE_KB)
    end

    def on_phone(chat_id, session, phone)
      normalized = phone.to_s.gsub(/[^\d+]/, "")
      if normalized.gsub(/\D/, "").length < 9
        return send_text(chat_id, "Raqam noto'g'ri ko'rinadi. Qaytadan yuboring (masalan: +998901234567).",
          reply_markup: PHONE_KB)
      end

      d = session.data
      booking = Booking.new(
        wash_id: d["wash_id"], service_id: d["service_id"],
        date: (Date.parse(d["date"]) rescue nil), slot: d["slot"],
        customer_name: d["name"], customer_phone: normalized,
        telegram_chat_id: chat_id
      )
      if booking.save
        session.reset!
        b = booking
        send_text(chat_id,
          "✅ Bron qabul qilindi!\n\n" \
          "🎫 Kod: #{b.code}\n" \
          "🚿 #{b.wash.name}\n" \
          "📍 #{b.wash.address}\n" \
          "🧽 #{b.service.name} — #{fmt_som(b.service.price)}\n" \
          "🕐 #{i_label(b.date)}, soat #{b.slot}\n\n" \
          "To'lov joyida — naqd yoki karta. " \
          "Bronlaringizni «#{BTN_MINE}» bo'limida ko'rasiz.",
          reply_markup: MAIN_KB)
      else
        send_text(chat_id,
          "Afsus, ulgurmadik: #{booking.errors.full_messages.to_sentence} 😕\n" \
          "Boshqa vaqtni tanlang:",
          reply_markup: { inline_keyboard: [ [ { text: "📅 Qayta tanlash", callback_data: "s:#{d['service_id']}" } ] ] })
        session.update!(step: "idle")
      end
    end

    # ---------- Bronlarim ----------

    def show_my_bookings(chat_id, session, phone: nil)
      scope = Booking.includes(:wash, :service).order(date: :desc, slot: :desc).limit(5)
      bookings = phone ? scope.where(customer_phone: phone) : scope.where(telegram_chat_id: chat_id)

      if bookings.empty? && phone.nil?
        session.update!(step: "lookup_phone")
        return send_text(chat_id,
          "Bu suhbatda bron topilmadi. Saytda bron qilgan bo'lsangiz, " \
          "telefon raqamingizni yuboring:", reply_markup: PHONE_KB)
      end
      if bookings.empty?
        session.reset!
        return send_text(chat_id, "Bu raqamda bron topilmadi. «#{BTN_FIND}» orqali yangi bron qiling!",
          reply_markup: MAIN_KB)
      end

      session.reset!
      bookings.each do |b|
        rows = b.cancellable? ? [ [ { text: "❌ Bekor qilish", callback_data: "c:#{b.code}" } ] ] : []
        send_text(chat_id,
          "🎫 #{b.code} — #{status_emoji(b)} #{b.status_label}\n" \
          "🚿 #{b.wash.name} · #{b.service.name}\n" \
          "🕐 #{i_label(b.date)}, #{b.slot}",
          reply_markup: rows.any? ? { inline_keyboard: rows } : MAIN_KB)
      end
    end

    def on_lookup_phone(chat_id, session, text)
      normalized = text.gsub(/[^\d+]/, "")
      show_my_bookings(chat_id, session, phone: normalized)
    end

    def on_cancel(chat_id, code)
      booking = Booking.find_by(code: code)
      if booking&.cancellable?
        booking.bekor!
        send_text(chat_id, "🎫 #{code} bekor qilindi.", reply_markup: MAIN_KB)
      else
        send_text(chat_id, "Bu bronni bekor qilib bo'lmaydi.", reply_markup: MAIN_KB)
      end
    end

    # ---------- Yordamchilar ----------

    def restart(chat_id, session)
      session.reset!
      send_text(chat_id, "Boshidan boshlaymiz:", reply_markup: MAIN_KB)
      show_districts(chat_id)
    end

    def send_text(chat_id, text, reply_markup: nil)
      # Telegram klaviaturani JSON-satr ko'rinishida kutadi
      markup = reply_markup.is_a?(Hash) ? reply_markup.to_json : reply_markup
      @api.send_message(chat_id: chat_id, text: text, reply_markup: markup)
    end

    def answer(cb)
      @api.answer_callback_query(callback_query_id: cb.id)
    rescue StandardError
      nil
    end

    def fmt_som(n)
      "#{n.to_s.gsub(/\B(?=(\d{3})+(?!\d))/, ' ')} so'm"
    end

    def i_label(date)
      case date
      when Date.current then "Bugun"
      when Date.current + 1 then "Ertaga"
      else "#{date.day}-#{UZ_MONTHS[date.month - 1]} (#{UZ_DAYS[date.wday]})"
      end
    end

    def status_emoji(b)
      { "yangi" => "🕐", "tasdiqlandi" => "👍", "bajarildi" => "✅", "bekor" => "❌" }[b.status]
    end
  end
end
